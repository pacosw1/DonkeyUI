import Foundation

// MARK: - AccountDisplayInfo

public struct AccountDisplayInfo {
    public let displayName: String
    public let email: String?
    public let avatarSystemIcon: String
    public let avatarURL: URL?
    public let memberSince: Date?

    public init(
        displayName: String,
        email: String? = nil,
        avatarSystemIcon: String = "person.circle.fill",
        avatarURL: URL? = nil,
        memberSince: Date? = nil
    ) {
        self.displayName = displayName
        self.email = email
        self.avatarSystemIcon = avatarSystemIcon
        self.avatarURL = avatarURL
        self.memberSince = memberSince
    }
}
