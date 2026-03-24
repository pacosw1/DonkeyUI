import SwiftUI

// MARK: - ImmersiveOnboardingFlow

/// A full-screen, immersive onboarding experience that progressively reveals content.
/// No skip button -- users must engage with each section before continuing.
///
/// Usage:
/// ```swift
/// ImmersiveOnboardingFlow(

///     sections: [welcomeSection, featuresSection],
///     manager: onboardingManager,
///     onComplete: { }
/// )
/// ```
public struct ImmersiveOnboardingFlow: View {
    let sections: [OnboardingSection]
    let onComplete: () -> Void
    let showProgressBar: Bool
    let progressBarColor: Color?
    let manager: OnboardingManager?
    let backgroundSound: String?
    let backgroundSoundVolume: Float
    let typingSound: TypingSoundStyle

    @State private var engine: RevealEngine
    @State private var celebrate = false
    @State private var musicPlayer: OnboardingMusicPlayer?
    @Environment(\.donkeyTheme) private var theme

    /// - Parameters:
    ///   - backgroundSound: Optional bundle sound file to loop during onboarding (e.g., "ambient.mp3").
    ///   - backgroundSoundVolume: Volume for background sound (0.0 to 1.0). Default 0.15 (subtle).
    ///   - typingSound: Sound played during typewriter text reveal. Default `.softTick`.
    public init(
        sections: [OnboardingSection],
        showProgressBar: Bool = true,
        progressBarColor: Color? = nil,
        manager: OnboardingManager? = nil,
        backgroundSound: String? = nil,
        backgroundSoundVolume: Float = 0.15,
        typingSound: TypingSoundStyle = .hapticOnly,
        onComplete: @escaping () -> Void
    ) {
        self.sections = sections
        self.onComplete = onComplete
        self.showProgressBar = showProgressBar
        self.progressBarColor = progressBarColor
        self.manager = manager
        self.backgroundSound = backgroundSound
        self.backgroundSoundVolume = backgroundSoundVolume
        self.typingSound = typingSound
        self._engine = State(initialValue: RevealEngine(sections: sections, typingSound: typingSound))
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            if showProgressBar {
                progressBar
            }

            // Section content
            sectionView
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Continue button
            continueButton
        }
        .background((engine.currentSection.backgroundColor ?? theme.colors.background).ignoresSafeArea())
        .celebration(isActive: $celebrate)
        .onAppear {
            // Resume from where the user left off if they killed the app
            let startIndex = resumeSectionIndex()
            engine.startSection(startIndex)

            // Start background music if provided
            if let sound = backgroundSound {
                musicPlayer = OnboardingMusicPlayer()
                musicPlayer?.play(sound, volume: backgroundSoundVolume)
            }
        }
        .onDisappear {
            engine.stop()
            musicPlayer?.stop()
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(theme.colors.borderSubtle)

                Rectangle()
                    .fill(progressBarColor ?? engine.currentSection.accentColor)
                    .frame(width: geo.size.width * sectionProgress)
                    .animation(.smoothSpring, value: engine.currentSectionIndex)
            }
        }
        .frame(height: 3)
    }

    private var sectionProgress: Double {
        guard engine.totalSections > 0 else { return 1.0 }
        return Double(engine.currentSectionIndex + 1) / Double(engine.totalSections)
    }

    // MARK: - Section View

    private var sectionView: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                // Section header (fades in when first block starts revealing)
                if let title = engine.currentSection.title {
                    let headerProgress = engine.revealedBlockCount > 0
                        ? 1.0
                        : engine.revealProgress(for: 0)
                    sectionHeader(title: title, subtitle: engine.currentSection.subtitle)
                        .opacity(min(1.0, headerProgress * 2)) // Fade in during first half of first block
                        .offset(y: (1 - min(1.0, headerProgress * 2)) * 10)
                        .animation(.gentleReveal, value: headerProgress)
                }

                // Content blocks
                ForEach(Array(engine.currentSection.blocks.enumerated()), id: \.offset) { index, block in
                    AnyView(block)
                        .environment(\.immersiveRevealProgress, engine.revealProgress(for: index))
                        .environment(\.immersiveRevealEngine, engine)
                }
            }
            .padding(.horizontal, theme.spacing.xl)
            .padding(.top, theme.spacing.xxl)
            .padding(.bottom, theme.spacing.xxxl + 80) // Space for continue button
        }
        .scrollIndicators(.hidden)
        .id(engine.currentSectionIndex) // Reset scroll position on section change
    }

    private func sectionHeader(title: String, subtitle: String?) -> some View {
        VStack(spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.largeTitle)
                .fontWeight(theme.typography.heavyWeight)
                .foregroundColor(theme.colors.onBackground)
                .multilineTextAlignment(.center)

            if let subtitle {
                Text(subtitle)
                    .font(theme.typography.subheadline)
                    .foregroundColor(theme.colors.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom, theme.spacing.md)
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        VStack(spacing: 0) {
            // Gradient fade above button
            LinearGradient(
                colors: [
                    (engine.currentSection.backgroundColor ?? theme.colors.background).opacity(0),
                    engine.currentSection.backgroundColor ?? theme.colors.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)

            VStack(spacing: theme.spacing.sm) {
                if engine.canContinue {
                    // Ready to continue -- pulses gently to invite tapping
                    ContinuePulseButton(
                        label: engine.isLastSection ? "Get Started" : engine.currentSection.continueButtonLabel,
                        icon: engine.isLastSection ? "checkmark" : "arrow.right",
                        action: handleContinue
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    // Wait indicator -- progress bar only
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(theme.colors.borderSubtle)

                            Capsule()
                                .fill(theme.colors.secondary.opacity(0.3))
                                .frame(width: geo.size.width * engine.sectionRevealProgress)
                                .animation(.linear(duration: 0.15), value: engine.sectionRevealProgress)
                        }
                    }
                    .frame(height: 14)
                    .padding(.horizontal, theme.spacing.xl)
                    .transition(.opacity)
                }

                // Section counter
                Text("\(engine.currentSectionIndex + 1) of \(engine.totalSections)")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.secondary)
            }
            .padding(.horizontal, theme.spacing.xl)
            .padding(.bottom, theme.spacing.xxl)
            .background(engine.currentSection.backgroundColor ?? theme.colors.background)
            .animation(.smoothSpring, value: engine.canContinue)
        }
    }

    // MARK: - Actions

    private func handleContinue() {
        guard engine.canContinue else { return }

        DonkeyHaptics.medium()

        // Persist section completion
        manager?.completeSection(engine.currentSection.id)

        if engine.currentSection.celebrateOnComplete {
            celebrate = true
        }

        if engine.isLastSection {
            musicPlayer?.stop()
            manager?.complete()
            onComplete()
        } else {
            withAnimation(.smoothSpring) {
                engine.advanceToNextSection()
            }
        }
    }

    // MARK: - Resume Support

    private func resumeSectionIndex() -> Int {
        guard let manager else { return 0 }
        for (i, section) in sections.enumerated() {
            if !manager.isSectionCompleted(section.id) {
                return i
            }
        }
        // All sections completed -- jump to the last one so user just taps "Get Started"
        return max(0, sections.count - 1)
    }
}

// MARK: - ContinuePulseButton

/// A ThemedButton that gently pulses with a breathing scale animation
/// to signal the user that it's ready to be tapped.
private struct ContinuePulseButton: View {
    let label: String
    let icon: String
    let action: () -> Void

    @State private var isPulsing = false

    var body: some View {
        ThemedButton(
            label,
            icon: icon,
            role: .primary,
            fullWidth: true,
            action: action
        )
        .scaleEffect(isPulsing ? 1.03 : 1.0)
        .shadow(
            color: .accentColor.opacity(isPulsing ? 0.3 : 0),
            radius: isPulsing ? 12 : 0
        )
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                isPulsing = true
            }
        }
    }
}

// MARK: - OnboardingMusicPlayer

#if canImport(AVFoundation)
import AVFoundation

/// Loops background music during the onboarding flow with fade-in/out support.
final class OnboardingMusicPlayer {
    private var player: AVAudioPlayer?

    func play(_ sound: String, volume: Float) {
        guard SoundManager.isEnabled else { return }

        let components = sound.split(separator: ".", maxSplits: 1)
        let name = String(components.first ?? "")
        let ext = components.count > 1 ? String(components.last!) : nil

        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }

        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = -1 // Loop forever
            audioPlayer.volume = 0 // Start silent for fade-in
            audioPlayer.play()
            self.player = audioPlayer

            // Fade in over 2 seconds
            fadeVolume(to: volume, duration: 2.0)
        } catch {
            // Silent fail
        }
    }

    func stop() {
        guard let player else { return }
        // Fade out over 1 second then stop
        fadeVolume(to: 0, duration: 1.0) {
            player.stop()
        }
    }

    private func fadeVolume(to target: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        guard let player else { return }
        let steps = 20
        let interval = duration / Double(steps)
        let volumeStep = (target - player.volume) / Float(steps)

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) { [weak player] in
                player?.volume += volumeStep
                if i == steps {
                    player?.volume = target
                    completion?()
                }
            }
        }
    }
}
#else
final class OnboardingMusicPlayer {
    func play(_ sound: String, volume: Float) {}
    func stop() {}
}
#endif

// MARK: - Demo Preview

/// Comprehensive 4-section demo onboarding showcasing all block types.
/// Open this preview in Xcode Canvas to experience the full immersive flow.
#Preview("Immersive Onboarding Demo") {
    ImmersiveOnboardingFlow(
        sections: [

            // ── Section 1: Welcome ──────────────────────────────
            OnboardingSection(
                title: "Welcome to DonkeyGo",
                subtitle: "Let's take a quick tour",
                accentColor: .blue,
                minimumDisplayTime: .seconds(4)
            ) {
                ImageRevealBlock(
                    .system("figure.walk.motion", .blue),
                    timing: .scaleIn
                )
                TextRevealBlock(
                    "Your personal movement companion",
                    font: .title2,
                    weight: .bold,
                    timing: RevealTiming(delay: .seconds(0.3), duration: .seconds(0.6), style: .fadeIn)
                )
                SpacerBlock(height: 12)
                TextRevealBlock(
                    "We'll walk you through each feature so you know exactly how everything works. No rushing — take your time reading each step.",
                    color: .secondary,
                    timing: RevealTiming(delay: .seconds(0.2), style: .typewriter(charactersPerSecond: 35))
                )
            },

            // ── Section 2: Key Features ─────────────────────────
            OnboardingSection(
                title: "What You Can Do",
                accentColor: .green,
                minimumDisplayTime: .seconds(6)
            ) {
                TextRevealBlock(
                    "Here's a quick look at the main features:",
                    color: .secondary,
                    timing: RevealTiming(duration: .seconds(0.5), style: .fadeIn)
                )
                SpacerBlock(height: 4)
                FeatureHighlightBlock(
                    icon: "map.fill",
                    iconColor: .green,
                    title: "Track Your Walks",
                    description: "See your routes on a map. Every walk is saved automatically so you never lose progress.",
                    timing: RevealTiming(delay: .seconds(0.4), duration: .seconds(0.5), style: .slideUp)
                )
                FeatureHighlightBlock(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: .blue,
                    title: "View Your Stats",
                    description: "Daily, weekly, and monthly charts show how active you've been. Watch your streaks grow!",
                    timing: RevealTiming(delay: .seconds(0.5), duration: .seconds(0.5), style: .slideUp)
                )
                FeatureHighlightBlock(
                    icon: "bell.badge.fill",
                    iconColor: .orange,
                    title: "Gentle Reminders",
                    description: "A friendly nudge at the time you choose. We'll never spam you — just one daily reminder.",
                    timing: RevealTiming(delay: .seconds(0.5), duration: .seconds(0.5), style: .slideUp)
                )
                FeatureHighlightBlock(
                    icon: "trophy.fill",
                    iconColor: .yellow,
                    title: "Earn Achievements",
                    description: "Complete challenges and collect badges. Share your milestones with friends.",
                    timing: RevealTiming(delay: .seconds(0.5), duration: .seconds(0.5), style: .slideUp)
                )
            },

            // ── Section 3: How Widgets Work ─────────────────────
            OnboardingSection(
                title: "Home Screen Widgets",
                subtitle: "Always at a glance",
                accentColor: .purple,
                minimumDisplayTime: .seconds(7)
            ) {
                TextRevealBlock(
                    "A widget is a small window that lives right on your phone's main screen.",
                    font: .body,
                    weight: .semibold,
                    timing: RevealTiming(duration: .seconds(1.5), style: .typewriter(charactersPerSecond: 30))
                )
                SpacerBlock(height: 8)
                TextRevealBlock(
                    "You can see your daily progress without even opening the app. It updates automatically throughout the day.",
                    color: .secondary,
                    timing: RevealTiming(delay: .seconds(0.3), style: .typewriter(charactersPerSecond: 32))
                )
                SpacerBlock(height: 12, showDivider: true)
                TextRevealBlock(
                    "How to add a widget:",
                    font: .headline,
                    alignment: .leading,
                    timing: RevealTiming(delay: .seconds(0.5), duration: .seconds(0.4), style: .fadeIn)
                )
                CardRevealBlock(timing: RevealTiming(delay: .seconds(0.3), duration: .seconds(0.5), style: .slideFromLeading)) {
                    HStack(spacing: 12) {
                        Text("1")
                            .font(.title3).fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.purple)
                            .clipShape(Circle())
                        Text("Long-press on your Home Screen until apps jiggle")
                            .font(.subheadline)
                    }
                }
                CardRevealBlock(timing: RevealTiming(delay: .seconds(0.4), duration: .seconds(0.5), style: .slideFromLeading)) {
                    HStack(spacing: 12) {
                        Text("2")
                            .font(.title3).fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.purple)
                            .clipShape(Circle())
                        Text("Tap the + button in the top corner")
                            .font(.subheadline)
                    }
                }
                CardRevealBlock(timing: RevealTiming(delay: .seconds(0.4), duration: .seconds(0.5), style: .slideFromLeading)) {
                    HStack(spacing: 12) {
                        Text("3")
                            .font(.title3).fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.purple)
                            .clipShape(Circle())
                        Text("Search for \"DonkeyGo\" and pick a size")
                            .font(.subheadline)
                    }
                }
            },

            // ── Section 4: Interactive + Get Started ────────────
            OnboardingSection(
                title: "Try It Out!",
                accentColor: .mint,
                minimumDisplayTime: .seconds(5),
                continueButtonLabel: "Get Started",
                celebrateOnComplete: true
            ) {
                TextRevealBlock(
                    "Let's make sure everything feels right. Tap the button below to see haptic feedback in action.",
                    color: .secondary,
                    timing: RevealTiming(duration: .seconds(1.2), style: .typewriter(charactersPerSecond: 35))
                )
                SpacerBlock(height: 8)
                InteractiveBlock(instruction: "Tap the circle to feel the haptic feedback") { completed in
                    Button {
                        DonkeyHaptics.medium()
                        completed.wrappedValue = true
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: completed.wrappedValue ? "checkmark.circle.fill" : "hand.tap.fill")
                                .font(.system(size: 48))
                                .foregroundColor(completed.wrappedValue ? .green : .mint)
                                .symbolEffect(.bounce, value: completed.wrappedValue)
                            Text(completed.wrappedValue ? "Nice!" : "Tap me")
                                .font(.headline)
                                .foregroundColor(completed.wrappedValue ? .green : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .background(Color.mint.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                SpacerBlock(height: 12)
                TextRevealBlock(
                    "You're all set! We're excited to have you here.",
                    font: .title3,
                    weight: .semibold,
                    timing: RevealTiming(delay: .seconds(0.3), duration: .seconds(0.6), style: .fadeIn)
                )
            },
        ],
        onComplete: {}
    )
}

// MARK: - Quick Preview (fast timing for Canvas testing)

#Preview("Quick Test") {
    ImmersiveOnboardingFlow(
        sections: [
            OnboardingSection(
                title: "Welcome",
                accentColor: .blue,
                minimumDisplayTime: .seconds(2)
            ) {
                ImageRevealBlock(
                    .system("star.fill", .blue),
                    timing: RevealTiming(duration: .seconds(0.5), style: .scaleIn)
                )
                TextRevealBlock(
                    "Hello, this is a test!",
                    font: .title2,
                    weight: .bold,
                    timing: RevealTiming(duration: .seconds(0.8), style: .fadeIn)
                )
                TextRevealBlock(
                    "This text types out character by character so you can read it naturally.",
                    timing: RevealTiming(delay: .seconds(0.3), style: .typewriter(charactersPerSecond: 40))
                )
                FeatureHighlightBlock(
                    icon: "heart.fill",
                    iconColor: .pink,
                    title: "Feature One",
                    description: "This card slides up into view.",
                    timing: RevealTiming(delay: .seconds(0.3), duration: .seconds(0.4), style: .slideUp)
                )
            },
            OnboardingSection(
                title: "Done!",
                accentColor: .green,
                minimumDisplayTime: .seconds(1),
                celebrateOnComplete: true
            ) {
                TextRevealBlock(
                    "That's it! You're ready to go.",
                    font: .title3,
                    weight: .semibold,
                    timing: RevealTiming(duration: .seconds(0.6), style: .fadeIn)
                )
            },
        ],
        onComplete: {}
    )
}

// MARK: - View Modifier

/// View modifier that shows an immersive onboarding flow on first launch.
public struct ImmersiveOnboardingModifier: ViewModifier {
    let manager: OnboardingManager
    let sections: [OnboardingSection]
    let showProgressBar: Bool
    let progressBarColor: Color?
    let onComplete: () -> Void

    public func body(content: Content) -> some View {
        if manager.hasCompleted {
            content
        } else {
            ImmersiveOnboardingFlow(
                sections: sections,
                showProgressBar: showProgressBar,
                progressBarColor: progressBarColor,
                manager: manager,
                onComplete: onComplete
            )
        }
    }
}

public extension View {
    /// Shows an immersive onboarding flow on first launch, then this view after completion.
    func immersiveOnboarding(
        manager: OnboardingManager,
        sections: [OnboardingSection],
        showProgressBar: Bool = true,
        progressBarColor: Color? = nil,
        onComplete: @escaping () -> Void = {}
    ) -> some View {
        modifier(ImmersiveOnboardingModifier(
            manager: manager,
            sections: sections,
            showProgressBar: showProgressBar,
            progressBarColor: progressBarColor,
            onComplete: onComplete
        ))
    }
}
