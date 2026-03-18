import Foundation

// MARK: - DonkeyCurrencyFormatter

public struct DonkeyCurrencyFormatter {

    /// Formats a decimal value as a localized currency string.
    ///
    /// - Parameters:
    ///   - value: The amount (e.g. 9.99).
    ///   - currencyCode: An ISO 4217 currency code (default: "USD").
    /// - Returns: A formatted string like "$9.99".
    public static func format(_ value: Double, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// Formats a value expressed in the currency's smallest unit (e.g. cents) as a
    /// localized currency string.
    ///
    /// - Parameters:
    ///   - cents: The amount in minor units (e.g. 999 for $9.99).
    ///   - currencyCode: An ISO 4217 currency code (default: "USD").
    /// - Returns: A formatted string like "$9.99".
    public static func formatCents(_ cents: Int, currencyCode: String = "USD") -> String {
        let value = Double(cents) / 100.0
        return format(value, currencyCode: currencyCode)
    }
}
