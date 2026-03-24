import SwiftUI

// MARK: - InteractiveBlock

/// A content block that pauses onboarding progression until the user completes an interaction.
/// The content closure receives a `Binding<Bool>` -- set it to `true` to signal completion.
///
/// Usage:
/// ```swift
/// InteractiveBlock(instruction: "Tap the widget to continue") { completed in
///     WidgetDemoView(onInteracted: { completed.wrappedValue = true })
/// }
/// ```
public struct InteractiveBlock: ContentBlock, View {
    public let id: String
    public let instruction: String?
    public let timing: RevealTiming
    private let content: (Binding<Bool>) -> AnyView

    @State private var isCompleted = false
    @Environment(\.donkeyTheme) private var theme
    @Environment(\.immersiveRevealProgress) private var progress: Double
    @Environment(\.immersiveRevealEngine) private var engine: RevealEngine?

    public init<Content: View>(
        id: String = UUID().uuidString,
        instruction: String? = nil,
        timing: RevealTiming = .standard,
        @ViewBuilder content: @escaping (Binding<Bool>) -> Content
    ) {
        self.id = id
        self.instruction = instruction
        self.timing = timing
        self.content = { binding in AnyView(content(binding)) }
    }

    public var body: some View {
        VStack(spacing: theme.spacing.md) {
            content($isCompleted)

            if let instruction, !isCompleted {
                Text(instruction)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.secondary)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }

            if isCompleted {
                HStack(spacing: theme.spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.colors.success)
                    Text("Done!")
                        .font(theme.typography.subheadline)
                        .fontWeight(theme.typography.emphasisWeight)
                        .foregroundColor(theme.colors.success)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.quickSpring, value: isCompleted)
        .modifier(RevealModifier(progress: progress, style: timing.style))
        .onChange(of: isCompleted) { _, completed in
            if completed {
                engine?.completeInteractiveBlock(id: id)
                DonkeyHaptics.success()
            }
        }
    }
}

// MARK: - Engine Environment Key

/// Environment key for passing the RevealEngine to InteractiveBlock children.
struct ImmersiveRevealEngineKey: EnvironmentKey {
    static let defaultValue: RevealEngine? = nil
}

extension EnvironmentValues {
    var immersiveRevealEngine: RevealEngine? {
        get { self[ImmersiveRevealEngineKey.self] }
        set { self[ImmersiveRevealEngineKey.self] = newValue }
    }
}
