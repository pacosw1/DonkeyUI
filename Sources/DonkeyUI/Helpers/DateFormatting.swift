import Foundation

// MARK: - DonkeyDateStyle

public enum DonkeyDateStyle {
    /// "2 days ago", "Just now"
    case relative
    /// "Mar 18"
    case short
    /// "March 18, 2026"
    case medium
    /// "Tuesday, March 18, 2026"
    case long
    /// "Member since March 2024"
    case memberSince
    /// "Expires March 18, 2026"
    case expiresOn
}

// MARK: - DonkeyDateFormatter

public struct DonkeyDateFormatter {

    /// Formats a date using the specified style.
    public static func format(_ date: Date, style: DonkeyDateStyle) -> String {
        switch style {
        case .relative:
            return relativeString(from: date)

        case .short:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)

        case .medium:
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter.string(from: date)

        case .long:
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .none
            return formatter.string(from: date)

        case .memberSince:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return "Member since \(formatter.string(from: date))"

        case .expiresOn:
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return "Expires \(formatter.string(from: date))"
        }
    }

    /// Returns a human-readable relative time string.
    ///
    /// - "Just now" (< 60 seconds)
    /// - "5m ago" (< 60 minutes)
    /// - "2h ago" (< 24 hours)
    /// - "Yesterday"
    /// - "3 days ago" (< 7 days)
    /// - "Mar 18" (>= 7 days)
    public static func relativeString(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents(
            [.second, .minute, .hour, .day],
            from: date,
            to: now
        )

        let seconds = components.second ?? 0
        let minutes = components.minute ?? 0
        let hours = components.hour ?? 0
        let days = components.day ?? 0

        // Future dates or just now
        if days < 0 || hours < 0 || minutes < 0 || seconds < 0 {
            return "Just now"
        }

        if days == 0 && hours == 0 && minutes == 0 {
            return "Just now"
        }

        if days == 0 && hours == 0 {
            return "\(minutes)m ago"
        }

        if days == 0 {
            return "\(hours)h ago"
        }

        if days == 1 {
            return "Yesterday"
        }

        if days < 7 {
            return "\(days) days ago"
        }

        // 7+ days: show short date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
