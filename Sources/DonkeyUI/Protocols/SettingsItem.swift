import SwiftUI

// MARK: - SettingsItemType

public enum SettingsItemType {
    case toggle(isOn: Binding<Bool>)
    case navigation
    case action(handler: () -> Void)
    case info(value: String)
    case destructiveAction(handler: () -> Void)
}

// MARK: - SettingsItem

public struct SettingsItem: Identifiable {
    public let id: String
    public let systemIcon: String
    public let iconColor: Color
    public let title: String
    public let subtitle: String?
    public let type: SettingsItemType
    public let badge: String?

    public init(
        id: String = UUID().uuidString,
        systemIcon: String,
        iconColor: Color,
        title: String,
        subtitle: String? = nil,
        type: SettingsItemType,
        badge: String? = nil
    ) {
        self.id = id
        self.systemIcon = systemIcon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.badge = badge
    }
}
