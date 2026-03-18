import SwiftUI

// MARK: - PaywallFeatureItem

public struct PaywallFeatureItem: Identifiable {
    public let id: String
    public let systemIcon: String
    public let iconColor: Color
    public let title: String
    public let description: String

    public init(
        id: String = UUID().uuidString,
        systemIcon: String,
        iconColor: Color = .accentColor,
        title: String,
        description: String
    ) {
        self.id = id
        self.systemIcon = systemIcon
        self.iconColor = iconColor
        self.title = title
        self.description = description
    }
}
