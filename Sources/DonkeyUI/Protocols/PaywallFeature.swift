import SwiftUI

// MARK: - Feature Icon

/// The icon for a feature — either an SF Symbol or an emoji.
public enum FeatureIcon {
    case system(name: String)
    case emoji(String)
}

// MARK: - PaywallFeatureItem

public struct PaywallFeatureItem: Identifiable {
    public let id: String
    public let icon: FeatureIcon
    public let iconColor: Color
    public let title: String
    public let description: String
    public let boldWord: String

    /// SF Symbol feature (title + description layout)
    public init(
        id: String = UUID().uuidString,
        systemIcon: String,
        iconColor: Color = .accentColor,
        title: String,
        description: String
    ) {
        self.id = id
        self.icon = .system(name: systemIcon)
        self.iconColor = iconColor
        self.title = title
        self.description = description
        self.boldWord = ""
    }

    /// Emoji feature (single line with optional bold word)
    public init(
        id: String = UUID().uuidString,
        emoji: String,
        color: Color,
        text: String,
        boldWord: String = ""
    ) {
        self.id = id
        self.icon = .emoji(emoji)
        self.iconColor = color
        self.title = text
        self.description = ""
        self.boldWord = boldWord
    }
}
