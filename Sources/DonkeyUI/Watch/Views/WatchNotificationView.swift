#if os(watchOS)
import SwiftUI

// MARK: - WatchNotificationView

public struct WatchNotificationView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let body: String

    @Environment(\.donkeyTheme) var theme

    public init(
        icon: String,
        iconColor: Color = .accentColor,
        title: String,
        body: String
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.body = body
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconColor)

                Text(title)
                    .font(theme.typography.headline)
                    .fontWeight(theme.typography.emphasisWeight)
                    .foregroundStyle(theme.colors.onBackground)
                    .lineLimit(2)
            }

            Text(self.body)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.onBackground.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

struct WatchNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        WatchNotificationView(
            icon: "bell.fill",
            iconColor: .orange,
            title: "Reminder",
            body: "Don't forget to complete your workout today."
        )
        .padding()
    }
}
#endif
