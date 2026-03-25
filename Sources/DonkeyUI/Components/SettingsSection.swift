import SwiftUI

// MARK: - SettingsSection

public struct SettingsSection: View {
    let header: String?
    let footer: String?
    let items: [SettingsItem]

    @Environment(\.donkeyTheme) var theme

    public init(
        header: String? = nil,
        footer: String? = nil,
        items: [SettingsItem]
    ) {
        self.header = header
        self.footer = footer
        self.items = items
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let header = header {
                Text(header.uppercased())
                    .font(theme.typography.caption)
                    .fontWeight(theme.typography.emphasisWeight)
                    .foregroundStyle(theme.colors.secondary)
                    .padding(.horizontal, theme.spacing.lg)
                    .padding(.bottom, theme.spacing.sm)
            }

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    settingsRow(for: item)

                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, item.systemIcon.isEmpty ? theme.spacing.lg : 60)
                    }
                }
            }
            .bgOverlay(
                bgColor: theme.colors.surface,
                radius: theme.shape.radiusMedium
            )

            if let footer = footer {
                Text(footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.secondary)
                    .padding(.horizontal, theme.spacing.lg)
                    .padding(.top, theme.spacing.sm)
            }
        }
    }

    @ViewBuilder
    private func settingsRow(for item: SettingsItem) -> some View {
        switch item.type {
        case .toggle(let isOn):
            ListRow(
                icon: item.systemIcon,
                iconColor: item.iconColor,
                title: item.title,
                subtitle: item.subtitle,
                accessory: .toggle(isOn)
            )

        case .navigation:
            ListRow(
                icon: item.systemIcon,
                iconColor: item.iconColor,
                title: item.title,
                subtitle: item.subtitle,
                accessory: item.badge != nil ? .badge(item.badge!, item.iconColor) : .chevron
            )

        case .action(let handler):
            ListRow(
                icon: item.systemIcon,
                iconColor: item.iconColor,
                title: item.title,
                subtitle: item.subtitle,
                accessory: .chevron,
                action: handler
            )

        case .info(let value):
            ListRow(
                icon: item.systemIcon,
                iconColor: item.iconColor,
                title: item.title,
                subtitle: item.subtitle,
                accessory: .info(value)
            )

        case .destructiveAction(let handler):
            Button(action: handler) {
                HStack(spacing: theme.spacing.md) {
                    if !item.systemIcon.isEmpty {
                        IconView(image: item.systemIcon, color: theme.colors.destructive, size: .small)
                    }

                    Text(item.title)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.destructive)

                    Spacer()
                }
                .padding(.vertical, theme.spacing.sm)
                .padding(.horizontal, theme.spacing.lg)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

struct SettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                SettingsSection(
                    header: "General",
                    footer: "Customize your experience.",
                    items: [
                        SettingsItem(
                            systemIcon: "bell.fill",
                            iconColor: .red,
                            title: "Notifications",
                            type: .toggle(isOn: .constant(true))
                        ),
                        SettingsItem(
                            systemIcon: "globe",
                            iconColor: .blue,
                            title: "Language",
                            type: .info(value: "English")
                        ),
                        SettingsItem(
                            systemIcon: "star.fill",
                            iconColor: .orange,
                            title: "Rate App",
                            type: .action(handler: {})
                        ),
                    ]
                )

                SettingsSection(items: [
                    SettingsItem(
                        systemIcon: "trash.fill",
                        iconColor: .red,
                        title: "Delete Account",
                        type: .destructiveAction(handler: {})
                    ),
                ])
            }
            .padding()
        }
    }
}
