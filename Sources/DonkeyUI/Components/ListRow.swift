import SwiftUI

// MARK: - ListRowAccessory

public enum ListRowAccessory {
    case chevron
    case toggle(Binding<Bool>)
    case badge(String, Color)
    case info(String)
    case none
}

// MARK: - ListRow

public struct ListRow: View {
    let icon: String?
    let iconColor: Color
    let title: String
    let subtitle: String?
    let accessory: ListRowAccessory
    let action: (() -> Void)?

    @Environment(\.donkeyTheme) var theme

    public init(
        icon: String? = nil,
        iconColor: Color = .accentColor,
        title: String,
        subtitle: String? = nil,
        accessory: ListRowAccessory = .none,
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
        let rowContent = HStack(spacing: theme.spacing.md) {
            if let icon = icon {
                IconView(image: icon, color: iconColor, size: .small)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(title)
                    .font(theme.typography.body)
                    .fontWeight(theme.typography.defaultWeight)
                    .foregroundColor(theme.colors.onSurface)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(theme.typography.footnote)
                        .foregroundColor(theme.colors.secondary)
                }
            }

            Spacer(minLength: 0)

            accessoryView
        }
        .padding(.vertical, theme.spacing.sm)
        .padding(.horizontal, theme.spacing.lg)
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
                .font(theme.typography.footnote)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.secondary.opacity(0.5))

        case .toggle(let binding):
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(theme.colors.primary)

        case .badge(let text, let color):
            Text(text)
                .font(theme.typography.caption)
                .fontWeight(theme.typography.emphasisWeight)
                .foregroundColor(.white)
                .padding(.horizontal, theme.spacing.sm)
                .padding(.vertical, theme.spacing.xs)
                .bgOverlay(bgColor: color, radius: theme.shape.radiusFull)

        case .info(let value):
            Text(value)
                .font(theme.typography.body)
                .foregroundColor(theme.colors.secondary)

        case .none:
            EmptyView()
        }
    }
}

// MARK: - Preview

struct ListRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ListRow(
                icon: "bell.fill",
                iconColor: .red,
                title: "Notifications",
                subtitle: "Manage alerts",
                accessory: .chevron,
                action: {}
            )
            Divider().padding(.leading, 60)

            ListRow(
                icon: "moon.fill",
                iconColor: .indigo,
                title: "Dark Mode",
                accessory: .toggle(.constant(true))
            )
            Divider().padding(.leading, 60)

            ListRow(
                icon: "star.fill",
                iconColor: .orange,
                title: "Rating",
                accessory: .info("4.8")
            )
            Divider().padding(.leading, 60)

            ListRow(
                icon: "envelope.fill",
                iconColor: .blue,
                title: "Messages",
                accessory: .badge("3", .red),
                action: {}
            )
        }
    }
}
