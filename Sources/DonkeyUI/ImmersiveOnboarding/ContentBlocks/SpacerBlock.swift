import SwiftUI

// MARK: - SpacerBlock

/// An animated spacer or divider between content blocks.
public struct SpacerBlock: ContentBlock, View {
    public let id: String
    public let height: CGFloat
    public let showDivider: Bool
    public let timing: RevealTiming

    @Environment(\.donkeyTheme) private var theme
    @Environment(\.immersiveRevealProgress) private var progress: Double

    public init(
        id: String = UUID().uuidString,
        height: CGFloat = 16,
        showDivider: Bool = false,
        timing: RevealTiming = RevealTiming(duration: .seconds(0.3), style: .fadeIn)
    ) {
        self.id = id
        self.height = height
        self.showDivider = showDivider
        self.timing = timing
    }

    public var body: some View {
        VStack(spacing: 0) {
            if showDivider {
                Rectangle()
                    .fill(theme.colors.borderSubtle)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .opacity(progress)
            }
            Spacer()
                .frame(height: height)
        }
    }
}
