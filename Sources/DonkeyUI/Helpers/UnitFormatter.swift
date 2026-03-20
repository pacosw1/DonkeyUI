import Foundation

// MARK: - UnitFormatter

public struct UnitFormatter {

    // MARK: - LiquidUnit

    public enum LiquidUnit: String, CaseIterable, Sendable {
        case milliliters = "ml"
        case liters = "L"
        case fluidOunces = "fl oz"
        case cups = "cups"
        case gallons = "gal"

        /// Conversion factor: how many milliliters per one of this unit
        fileprivate var mlPerUnit: Double {
            switch self {
            case .milliliters: return 1.0
            case .liters:      return 1_000.0
            case .fluidOunces: return 29.5735
            case .cups:        return 236.588
            case .gallons:     return 3_785.41
            }
        }
    }

    // MARK: - Liquid formatting

    /// Format a value in milliliters to the specified unit.
    public static func formatLiquid(_ ml: Double, unit: LiquidUnit, decimals: Int = 0) -> String {
        let converted = convert(ml, from: .milliliters, to: unit)
        return withUnit(converted, unit: unit.rawValue, decimals: decimals)
    }

    /// Convert between liquid units.
    public static func convert(_ value: Double, from: LiquidUnit, to: LiquidUnit) -> Double {
        let ml = value * from.mlPerUnit
        return ml / to.mlPerUnit
    }

    // MARK: - Number formatting

    /// Format large numbers compactly: 1234 -> "1.2K", 1500000 -> "1.5M"
    public static func compact(_ value: Double) -> String {
        let abs = Swift.abs(value)
        let sign = value < 0 ? "-" : ""

        switch abs {
        case 1_000_000_000...:
            return "\(sign)\(trimmed(abs / 1_000_000_000, decimals: 1))B"
        case 1_000_000...:
            return "\(sign)\(trimmed(abs / 1_000_000, decimals: 1))M"
        case 1_000...:
            return "\(sign)\(trimmed(abs / 1_000, decimals: 1))K"
        default:
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            return sign + (formatter.string(from: NSNumber(value: abs)) ?? "\(Int(abs))")
        }
    }

    /// Format with a unit suffix: 1234, "steps" -> "1,234 steps"
    public static func withUnit(_ value: Double, unit: String, decimals: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        let num = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(decimals)f", value)
        return "\(num) \(unit)"
    }

    /// Format percentage: 0.756 -> "75.6%"
    public static func percentage(_ value: Double, decimals: Int = 0) -> String {
        let pct = value * 100.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        let num = formatter.string(from: NSNumber(value: pct)) ?? String(format: "%.\(decimals)f", pct)
        return "\(num)%"
    }

    // MARK: - Private

    /// Trim trailing zeros: 1.0 -> "1", 1.2 -> "1.2"
    private static func trimmed(_ value: Double, decimals: Int) -> String {
        let s = String(format: "%.\(decimals)f", value)
        if s.contains(".") {
            let stripped = s.replacingOccurrences(of: "0+$", with: "", options: .regularExpression)
            return stripped.hasSuffix(".") ? String(stripped.dropLast()) : stripped
        }
        return s
    }
}
