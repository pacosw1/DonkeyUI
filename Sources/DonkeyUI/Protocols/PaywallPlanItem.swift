import Foundation

// MARK: - PaywallPlanOption

public struct PaywallPlanOption: Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let priceDisplay: String
    public let period: String
    public let isBestValue: Bool
    public let isTrial: Bool
    public let trialDescription: String?

    public init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String = "",
        priceDisplay: String,
        period: String,
        isBestValue: Bool = false,
        isTrial: Bool = false,
        trialDescription: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.priceDisplay = priceDisplay
        self.period = period
        self.isBestValue = isBestValue
        self.isTrial = isTrial
        self.trialDescription = trialDescription
    }
}
