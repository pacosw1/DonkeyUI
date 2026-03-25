#if canImport(Charts)
import Foundation

public protocol DonkeyChartable: Identifiable {
    var label: String { get }
    var value: Double { get }
}

public struct DonkeyChartItem: DonkeyChartable, Sendable {
    public let id: String
    public let label: String
    public let value: Double
    public let category: String?
    public let date: Date?

    public init(
        id: String = UUID().uuidString,
        label: String,
        value: Double,
        category: String? = nil,
        date: Date? = nil
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.category = category
        self.date = date
    }
}
#endif
