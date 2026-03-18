import SwiftUI

// MARK: - OnboardingMedia

public enum OnboardingMedia {
    case systemIcon(name: String, color: Color)
    case image(name: String)
    case custom(AnyView)
}

// MARK: - OnboardingPageItem

public struct OnboardingPageItem: Identifiable {
    public let id: String
    public let media: OnboardingMedia
    public let title: String
    public let description: String
    public let accentColor: Color

    public init(
        id: String = UUID().uuidString,
        media: OnboardingMedia,
        title: String,
        description: String,
        accentColor: Color = .accentColor
    ) {
        self.id = id
        self.media = media
        self.title = title
        self.description = description
        self.accentColor = accentColor
    }
}
