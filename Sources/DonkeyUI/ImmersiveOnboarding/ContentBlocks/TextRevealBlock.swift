import SwiftUI

// MARK: - TextRevealBlock

/// A text block that reveals progressively via typewriter or word-by-word animation.
public struct TextRevealBlock: ContentBlock, View {
    public let id: String
    public let text: String
    public let font: Font
    public let weight: Font.Weight?
    public let color: Color?
    public let alignment: TextAlignment
    public let timing: RevealTiming
    public let hapticOnReveal: Bool

    @Environment(\.donkeyTheme) private var theme

    public init(
        id: String = UUID().uuidString,
        _ text: String,
        font: Font = .body,
        weight: Font.Weight? = nil,
        color: Color? = nil,
        alignment: TextAlignment = .center,
        timing: RevealTiming = .typewriter,
        hapticOnReveal: Bool = false
    ) {
        self.id = id
        self.text = text
        self.font = font
        self.weight = weight
        self.color = color
        self.alignment = alignment
        self.timing = timing
        self.hapticOnReveal = hapticOnReveal
    }

    public var estimatedDuration: Duration {
        switch timing.style {
        case .typewriter(let cps):
            let baseMs = Double(text.count) / cps * 1000
            // Account for sentence/punctuation pauses
            let pauseMs = Self.estimatePauseMs(in: text)
            return .milliseconds(Int(baseMs + pauseMs))
        case .wordByWord(let interval):
            let wordCount = text.split(separator: " ").count
            let ms = interval.totalMilliseconds * Double(wordCount)
            return .milliseconds(Int(ms))
        default:
            return timing.duration
        }
    }

    private static func estimatePauseMs(in text: String) -> Double {
        var ms: Double = 0
        let chars = Array(text)
        for (i, c) in chars.enumerated() {
            let nextSpace = (i + 1 < chars.count) && chars[i + 1] == " "
            if (c == "." || c == "!" || c == "?") && nextSpace { ms += 400 }
            else if c == "," && nextSpace { ms += 150 }
            else if c == ":" || c == ";" { ms += 200 }
        }
        return ms
    }

    public var body: some View {
        TextRevealContent(
            text: text,
            font: font,
            weight: weight,
            color: color ?? theme.colors.onBackground,
            alignment: alignment,
            style: timing.style,
            hapticOnReveal: hapticOnReveal
        )
    }
}

// MARK: - TextRevealContent

/// Internal view that renders text based on reveal progress from the engine.
struct TextRevealContent: View {
    let text: String
    let font: Font
    let weight: Font.Weight?
    let color: Color
    let alignment: TextAlignment
    let style: RevealStyle
    let hapticOnReveal: Bool

    @Environment(\.immersiveRevealProgress) private var progress: Double
    @State private var lastHapticWord: Int = -1

    var body: some View {
        switch style {
        case .typewriter:
            typewriterView
        case .wordByWord:
            wordByWordView
        default:
            fadeView
        }
    }

    // MARK: - Typewriter

    private var typewriterView: some View {
        let charCount = max(0, Int(progress * Double(text.count)))
        let visible = String(text.prefix(charCount))
        // Pad with invisible remaining text to reserve the full layout height
        let remaining = String(text.suffix(text.count - charCount))

        return (
            Text(visible)
                .font(font)
                .fontWeight(weight)
                .foregroundColor(color)
            +
            Text(remaining)
                .font(font)
                .fontWeight(weight)
                .foregroundColor(.clear)
        )
        .multilineTextAlignment(alignment)
        .frame(maxWidth: .infinity, alignment: textFrameAlignment)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Word by Word

    private var wordByWordView: some View {
        let words = text.split(separator: " ", omittingEmptySubsequences: false)
        let wordCount = Double(words.count)

        // Each word fades in over a window instead of snapping.
        // fadeWindow controls how much of the 0...1 progress range each word
        // uses to transition from invisible to visible.
        let fadeWindow = 1.0 / max(1, wordCount) * 0.6

        return wordByWordText(words: words, fadeWindow: fadeWindow)
            .onChange(of: currentWordIndex(wordCount: words.count)) { _, newIndex in
                if hapticOnReveal && newIndex > lastHapticWord {
                    lastHapticWord = newIndex
                    DonkeyHaptics.light()
                }
            }
    }

    private func currentWordIndex(wordCount: Int) -> Int {
        max(0, Int(progress * Double(wordCount)))
    }

    private func wordByWordText(words: [Substring], fadeWindow: Double) -> some View {
        let wordCount = Double(words.count)
        var result = Text("")
        for (i, word) in words.enumerated() {
            let separator = i > 0 ? " " : ""
            // Each word starts becoming visible when progress reaches its threshold
            let wordThreshold = Double(i) / max(1, wordCount)
            let wordProgress = min(1.0, max(0.0, (progress - wordThreshold) / fadeWindow))
            result = result + Text(separator + word)
                .font(font)
                .fontWeight(weight)
                .foregroundColor(color.opacity(wordProgress))
        }
        return result
            .multilineTextAlignment(alignment)
            .frame(maxWidth: .infinity, alignment: textFrameAlignment)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Fade

    private var fadeView: some View {
        Text(text)
            .font(font)
            .fontWeight(weight)
            .foregroundColor(color)
            .multilineTextAlignment(alignment)
            .frame(maxWidth: .infinity, alignment: textFrameAlignment)
            .fixedSize(horizontal: false, vertical: true)
            .opacity(progress)
    }

    private var textFrameAlignment: Alignment {
        switch alignment {
        case .leading: return .leading
        case .trailing: return .trailing
        default: return .center
        }
    }
}

// MARK: - Environment Key for Reveal Progress

/// Environment key that passes reveal progress (0...1) from the engine to content block views.
struct ImmersiveRevealProgressKey: EnvironmentKey {
    static let defaultValue: Double = 0.0
}

extension EnvironmentValues {
    var immersiveRevealProgress: Double {
        get { self[ImmersiveRevealProgressKey.self] }
        set { self[ImmersiveRevealProgressKey.self] = newValue }
    }
}
