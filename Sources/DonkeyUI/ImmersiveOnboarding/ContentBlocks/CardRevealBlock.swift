import SwiftUI

// MARK: - CardRevealBlock

/// A generic card container that slides into view during onboarding.
/// Wraps arbitrary SwiftUI content in a themed card.
public struct CardRevealBlock<Content: View>: ContentBlock, View {
    public let id: String
    public let timing: RevealTiming
    private let content: () -> Content

    @Environment(\.donkeyTheme) private var theme
    @Environment(\.immersiveRevealProgress) private var progress: Double

    public init(
        id: String = UUID().uuidString,
        timing: RevealTiming = .slideUp,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.id = id
        self.timing = timing
        self.content = content
    }

    public var body: some View {
        content()
            .padding(theme.spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.shape.radiusMedium, style: .continuous))
            .modifier(RevealModifier(progress: progress, style: timing.style))
    }
}
