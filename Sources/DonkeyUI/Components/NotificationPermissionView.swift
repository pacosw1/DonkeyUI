import SwiftUI

// MARK: - NotificationPermissionView

public struct NotificationPermissionView: View {
    let title: String
    let description: String
    let features: [String]
    let onEnable: () -> Void
    let onSkip: () -> Void

    @Environment(\.donkeyTheme) var theme

    public init(
        title: String = "Stay in the Loop",
        description: String = "Get notified about what matters most to you.",
        features: [String],
        onEnable: @escaping () -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.features = features
        self.onEnable = onEnable
        self.onSkip = onSkip
    }

    public var body: some View {
        VStack(spacing: theme.spacing.xxl) {
            Spacer()

            // Icon
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 56))
                .fontWeight(.light)
                .symbolRenderingMode(.palette)
                .foregroundStyle(theme.colors.primary, theme.colors.error)
                .frame(width: 110, height: 110)
                .bgOverlay(
                    bgColor: theme.colors.primary.opacity(0.1),
                    radius: theme.shape.radiusXL
                )

            // Title & description
            VStack(spacing: theme.spacing.sm) {
                Text(title)
                    .font(theme.typography.title2)
                    .fontWeight(theme.typography.heavyWeight)
                    .foregroundColor(theme.colors.onBackground)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, theme.spacing.xl)

            // Feature bullets
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                ForEach(Array(features.enumerated()), id: \.offset) { _, feature in
                    HStack(spacing: theme.spacing.md) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(theme.typography.callout)
                            .foregroundColor(theme.colors.success)

                        Text(feature)
                            .font(theme.typography.body)
                            .foregroundColor(theme.colors.onBackground)
                    }
                }
            }
            .padding(theme.spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .bgOverlay(
                bgColor: theme.colors.surface,
                radius: theme.shape.radiusMedium
            )
            .padding(.horizontal, theme.spacing.xl)

            Spacer()

            // Actions
            VStack(spacing: theme.spacing.md) {
                ThemedButton("Enable Notifications", icon: "bell", role: .primary, fullWidth: true) {
                    DonkeyHaptics.medium()
                    onEnable()
                }

                Button {
                    DonkeyHaptics.light()
                    onSkip()
                } label: {
                    Text("Not Now")
                        .font(theme.typography.callout)
                        .fontWeight(theme.typography.emphasisWeight)
                        .foregroundColor(theme.colors.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacing.md)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, theme.spacing.xl)
            .padding(.bottom, theme.spacing.xl)
        }
    }
}

// MARK: - Preview

struct NotificationPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPermissionView(
            title: "Stay in the Loop",
            description: "Get notified about what matters most to you.",
            features: [
                "Daily hydration reminders",
                "Weekly progress reports",
                "Goal completion celebrations",
                "Streak alerts so you never miss a day"
            ],
            onEnable: {},
            onSkip: {}
        )
    }
}
