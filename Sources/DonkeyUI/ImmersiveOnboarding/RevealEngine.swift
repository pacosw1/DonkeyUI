import SwiftUI

// MARK: - RevealEngine

/// Orchestrates the progressive reveal of content blocks within an immersive onboarding section.
/// Manages timing, sequencing, and the "can continue" gate.
@Observable
@MainActor
public final class RevealEngine {

    // MARK: - Public State

    /// Index of the current section being displayed.
    public private(set) var currentSectionIndex: Int = 0

    /// Number of blocks that have been fully revealed in the current section.
    public private(set) var revealedBlockCount: Int = 0

    /// Whether the user can tap "Continue" (all blocks revealed + minimum time elapsed).
    public private(set) var canContinue: Bool = false

    /// Per-block reveal progress (0.0 to 1.0), keyed by block ID.
    public private(set) var blockProgress: [String: Double] = [:]

    /// Time elapsed since the current section started.
    public private(set) var sectionElapsedTime: Duration = .zero

    /// Whether the entire flow is complete.
    public private(set) var isFlowComplete: Bool = false

    // MARK: - Private

    private let sections: [OnboardingSection]
    private var revealTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?
    private var interactiveCompletions: Set<String> = []
    private var typingSoundEngine: TypingSoundEngine?

    // MARK: - Init

    public init(sections: [OnboardingSection], typingSound: TypingSoundStyle = .hapticOnly) {
        self.sections = sections
        self.typingSoundEngine = TypingSoundEngine(style: typingSound)
    }

    // MARK: - Computed

    public var currentSection: OnboardingSection {
        guard currentSectionIndex < sections.count else {
            return sections.last ?? OnboardingSection { SpacerBlock() }
        }
        return sections[currentSectionIndex]
    }

    public var overallProgress: Double {
        guard !sections.isEmpty else { return 1.0 }
        return Double(currentSectionIndex) / Double(sections.count)
    }

    public var isLastSection: Bool {
        currentSectionIndex >= sections.count - 1
    }

    public var totalSections: Int {
        sections.count
    }

    /// How far along the current section's reveal is (0...1).
    /// Driven by elapsed time vs estimated total time for a smooth, linear fill.
    public var sectionRevealProgress: Double {
        let section = currentSection
        guard !section.blocks.isEmpty else { return 1.0 }

        // Estimate total time: sum of all block durations (including delays) + minimum display time buffer
        var estimatedMs: Double = 600 // initial entrance pause
        for block in section.blocks {
            estimatedMs += block.timing.delay.totalMilliseconds
            if let textBlock = block as? TextRevealBlock {
                estimatedMs += textBlock.estimatedDuration.totalMilliseconds
            } else {
                estimatedMs += block.timing.duration.totalMilliseconds
            }
        }
        // Ensure we account for minimum display time
        estimatedMs = max(estimatedMs, section.minimumDisplayTime.totalMilliseconds)

        let elapsedMs = sectionElapsedTime.totalMilliseconds
        return min(1.0, elapsedMs / max(1, estimatedMs))
    }

    /// Get the reveal progress for a block at the given index in the current section.
    public func revealProgress(for blockIndex: Int) -> Double {
        guard blockIndex < currentSection.blocks.count else { return 0 }
        let blockID = currentSection.blocks[blockIndex].id
        return blockProgress[blockID] ?? 0
    }

    // MARK: - Actions

    /// Begin revealing blocks for the given section index.
    public func startSection(_ index: Int) {
        guard index < sections.count else { return }

        // Cancel any running tasks
        revealTask?.cancel()
        timerTask?.cancel()

        currentSectionIndex = index
        revealedBlockCount = 0
        canContinue = false
        blockProgress = [:]
        sectionElapsedTime = .zero
        interactiveCompletions = []

        // Start wall-clock timer
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                guard !Task.isCancelled else { return }
                self?.sectionElapsedTime += .milliseconds(100)
            }
        }

        // Start sequential reveal
        revealTask = Task { [weak self] in
            guard let self else { return }
            let section = self.sections[index]

            // Brief pause before content starts (let the page settle)
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled else { return }

            for (i, block) in section.blocks.enumerated() {
                guard !Task.isCancelled else { return }

                // Wait for delay
                if block.timing.delay > .zero {
                    try? await Task.sleep(for: block.timing.delay)
                }

                guard !Task.isCancelled else { return }

                // Check if this is an interactive block that needs user completion
                let isInteractive = block is InteractiveBlock

                // Animate the reveal -- typewriter blocks get sentence-pause awareness
                if let textBlock = block as? TextRevealBlock,
                   case .typewriter(let cps) = block.timing.style {
                    await self.animateTypewriter(id: block.id, text: textBlock.text, cps: cps)
                } else {
                    let duration = self.effectiveDuration(for: block)
                    await self.animateBlock(id: block.id, duration: duration, style: block.timing.style)
                }

                guard !Task.isCancelled else { return }

                // Subtle haptic tick when each block finishes revealing
                DonkeyHaptics.selection()

                // For interactive blocks, wait until user completes the interaction
                if isInteractive {
                    while !self.interactiveCompletions.contains(block.id) && !Task.isCancelled {
                        try? await Task.sleep(for: .milliseconds(50))
                    }
                }

                guard !Task.isCancelled else { return }
                self.revealedBlockCount = i + 1
            }

            // All blocks revealed -- wait for minimum display time if needed
            let remaining = section.minimumDisplayTime - self.sectionElapsedTime
            if remaining > .zero {
                try? await Task.sleep(for: remaining)
            }

            guard !Task.isCancelled else { return }
            self.canContinue = true
            DonkeyHaptics.light()
        }
    }

    /// Advance to the next section. Called when user taps Continue.
    public func advanceToNextSection() {
        if isLastSection {
            revealTask?.cancel()
            timerTask?.cancel()
            isFlowComplete = true
        } else {
            startSection(currentSectionIndex + 1)
        }
    }

    /// Signal that an interactive block has been completed by the user.
    public func completeInteractiveBlock(id: String) {
        interactiveCompletions.insert(id)
    }

    /// Clean up tasks when the engine is no longer needed.
    public func stop() {
        revealTask?.cancel()
        timerTask?.cancel()
    }

    // MARK: - Private Helpers

    private func effectiveDuration(for block: any ContentBlock) -> Duration {
        switch block.timing.style {
        case .typewriter(let cps):
            if let textBlock = block as? TextRevealBlock {
                let charCount = Double(textBlock.text.count)
                let baseMs = charCount / cps * 1000
                // Account for sentence/punctuation pauses
                let pauseMs = Self.estimatePauseTime(in: textBlock.text)
                return .milliseconds(Int(baseMs + pauseMs))
            }
            return block.timing.duration

        case .wordByWord(let interval):
            if let textBlock = block as? TextRevealBlock {
                let wordCount = textBlock.text.split(separator: " ").count
                let intervalMs: Int = Int(interval.totalMilliseconds)
                let totalMs: Int = intervalMs * wordCount
                return .milliseconds(totalMs)
            }
            return block.timing.duration

        default:
            return block.timing.duration
        }
    }

    /// Typewriter animation with natural pauses at sentence endings and commas.
    /// Characters appear at a constant rate, but the engine pauses briefly after
    /// sentence-ending punctuation (. ! ?) and slightly after commas.
    private func animateTypewriter(id: String, text: String, cps: Double) async {
        let chars = Array(text)
        let totalChars = chars.count
        guard totalChars > 0 else {
            blockProgress[id] = 1.0
            return
        }

        // Start looping sound + haptic pattern
        typingSoundEngine?.start()

        let msPerChar = 1000.0 / cps

        for i in 0..<totalChars {
            guard !Task.isCancelled else {
                typingSoundEngine?.stop()
                return
            }

            let progress = Double(i + 1) / Double(totalChars)
            blockProgress[id] = progress

            let char = chars[i]

            // Per-character sound tick (haptics are handled by the looping pattern)
            if !char.isWhitespace && !char.isPunctuation {
                typingSoundEngine?.onCharacterRevealed()
            }
            let isEndOfSentence = (char == "." || char == "!" || char == "?")
            let nextIsSpace = (i + 1 < totalChars) && chars[i + 1] == " "

            if isEndOfSentence && nextIsSpace {
                // Sentence boundary: pause everything
                typingSoundEngine?.stop()
                try? await Task.sleep(for: .milliseconds(400))
                typingSoundEngine?.start()
            } else if char == "," && nextIsSpace {
                typingSoundEngine?.stop()
                try? await Task.sleep(for: .milliseconds(150))
                typingSoundEngine?.start()
            } else if char == ":" || char == ";" {
                typingSoundEngine?.stop()
                try? await Task.sleep(for: .milliseconds(200))
                typingSoundEngine?.start()
            } else {
                try? await Task.sleep(for: .milliseconds(Int(msPerChar)))
            }
        }

        typingSoundEngine?.stop()
        blockProgress[id] = 1.0
    }

    private func animateBlock(id: String, duration: Duration, style: RevealStyle) async {
        let totalMs = duration.totalMilliseconds
        let frameInterval: Int = 16 // ~60fps
        let totalFrames = max(1, Int(totalMs) / frameInterval)

        // Typewriter and word-by-word use linear progress (constant rate).
        // Other styles use easeInOut for smoother visual motion.
        let useLinear: Bool = {
            switch style {
            case .typewriter, .wordByWord: return true
            default: return false
            }
        }()

        for frame in 0..<totalFrames {
            guard !Task.isCancelled else { return }
            let linear = Double(frame) / Double(totalFrames)
            blockProgress[id] = useLinear ? linear : Self.easeInOut(linear)
            try? await Task.sleep(for: .milliseconds(frameInterval))
        }

        blockProgress[id] = 1.0
    }

    /// Estimates total pause time in milliseconds for sentence/punctuation breaks in text.
    private static func estimatePauseTime(in text: String) -> Double {
        var pauseMs: Double = 0
        let chars = Array(text)
        for (i, char) in chars.enumerated() {
            let nextIsSpace = (i + 1 < chars.count) && chars[i + 1] == " "
            if (char == "." || char == "!" || char == "?") && nextIsSpace {
                pauseMs += 400
            } else if char == "," && nextIsSpace {
                pauseMs += 150
            } else if char == ":" || char == ";" {
                pauseMs += 200
            }
        }
        return pauseMs
    }

    private static func easeInOut(_ t: Double) -> Double {
        t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }
}

// MARK: - Duration Helpers

extension Duration {
    var totalMilliseconds: Double {
        let (seconds, attoseconds) = self.components
        return Double(seconds) * 1000.0 + Double(attoseconds) / 1_000_000_000_000_000.0
    }
}
