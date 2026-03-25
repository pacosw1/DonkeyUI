#if os(watchOS)
import SwiftUI

// MARK: - WatchListRowAccessory

public enum WatchListRowAccessory {
    case chevron
    case info(String)
    case none
}

// MARK: - WatchListRow

public struct WatchListRow: View {
    let icon: String?
    let iconColor: Color
    let title: String
    let subtitle: String?
    let accessory: WatchListRowAccessory
    let action: (() -> Void)?

    @Environment(\.donkeyTheme) var theme

    public init(
        icon: String? = nil,
        iconColor: Color = .accentColor,
        title: String,
        subtitle: String? = nil,
        accessory: WatchListRowAccessory = .none,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.accessory = accessory
        self.action = action
    }

    public var body: some View {
        let rowContent = HStack(spacing: theme.spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
                    .frame(width: 28, height: 28)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(title)
                    .font(theme.typography.body)
                    .fontWeight(theme.typography.emphasisWeight)
                    .foregroundColor(theme.colors.onSurface)
                    .lineLimit(2)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            accessoryView
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())

        if let action = action {
            Button(action: action) {
                rowContent
            }
            .buttonStyle(.plain)
        } else {
            rowContent
        }
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .chevron:
            Image(systemName: "chevron.right")
                .font(theme.typography.caption)
                .fontWeight(.bold)
                .foregroundColor(theme.colors.secondary.opacity(0.5))

        case .info(let value):
            Text(value)
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.secondary)

        case .none:
            EmptyView()
        }
    }
}

// MARK: - Preview

struct WatchListRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            WatchListRow(
                icon: "bell.fill",
                iconColor: .red,
                title: "Notifications",
                accessory: .chevron,
                action: {}
            )
            WatchListRow(
                icon: "star.fill",
                iconColor: .orange,
                title: "Rating",
                subtitle: "Your current score",
                accessory: .info("4.8")
            )
            WatchListRow(
                icon: "gear",
                iconColor: .gray,
                title: "Settings",
                accessory: .chevron,
                action: {}
            )
        }
    }
}
#endif
