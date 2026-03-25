import SwiftUI

// MARK: - FeatureHighlightBlock

/// A feature highlight card showing an icon, title, and description.
/// Ideal for showcasing app features during onboarding.
public struct FeatureHighlightBlock: ContentBlock, View {
    public let id: String
    public let icon: String
    public let iconColor: Color
    public let title: String
    public let description: String
    public let timing: RevealTiming

    @Environment(\.donkeyTheme) private var theme
    @Environment(\.immersiveRevealProgress) private var progress: Double

    public init(
        id: String = UUID().uuidString,
        icon: String,
        iconColor: Color = .accentColor,
        title: String,
        description: String,
        timing: RevealTiming = .slideUp
    ) {
        self.id = id
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
        self.timing = timing
    }

    public var body: some View {
        HStack(spacing: theme.spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .fontWeight(.medium)
                .foregroundStyle(iconColor)
                .frame(width: 52, height: 52)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: theme.shape.radiusMedium, style: .continuous))

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(title)
                    .font(theme.typography.headline)
                    .fontWeight(theme.typography.emphasisWeight)
                    .foregroundStyle(theme.colors.onBackground)

                Text(description)
                    .font(theme.typography.subheadline)
                    .foregroundStyle(theme.colors.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(theme.spacing.lg)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.shape.radiusMedium, style: .continuous))
        .modifier(RevealModifier(progress: progress, style: timing.style))
    }
}
