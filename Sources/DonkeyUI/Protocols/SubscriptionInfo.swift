import Foundation

// MARK: - SubscriptionStatus

public enum SubscriptionStatus: String {
    case active
    case trial
    case expired
    case cancelled
    case free
    case unknown
}

// MARK: - SubscriptionDisplayInfo

public struct SubscriptionDisplayInfo {
    public let planName: String
    public let status: SubscriptionStatus
    public let expiresAt: Date?
    public let isTrial: Bool
    public let renewsAutomatically: Bool
    public let managementURL: URL?

    public init(
        planName: String,
        status: SubscriptionStatus = .unknown,
        expiresAt: Date? = nil,
        isTrial: Bool = false,
        renewsAutomatically: Bool = true,
        managementURL: URL? = nil
    ) {
        self.planName = planName
        self.status = status
        self.expiresAt = expiresAt
        self.isTrial = isTrial
        self.renewsAutomatically = renewsAutomatically
        self.managementURL = managementURL
    }
}
