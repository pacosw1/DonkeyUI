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

    /// Formats a duration in seconds as a timer string.
    ///
    /// - Returns `"MM:SS"` when under 1 hour, `"H:MM:SS"` otherwise.
    ///
    /// ```swift
    /// DonkeyDateFormatter.formatTimer(seconds: 125)  // "2:05"
    /// DonkeyDateFormatter.formatTimer(seconds: 3661) // "1:01:01"
    /// ```
    public static func formatTimer(seconds: Int) -> String {
        let clamped = max(0, seconds)
        let h = clamped / 3600
        let m = (clamped % 3600) / 60
        let s = clamped % 60

        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    // MARK: - API Date Coding (matches donkey-swift server format)

    /// Shared ISO8601 formatter with fractional seconds for API encoding.
    private static let isoWithFrac: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    /// Shared ISO8601 formatter without fractional seconds (fallback).
    private static let isoNoFrac: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    /// Date-only formatter for "YYYY-MM-DD" strings (task dates without time).
    private static let dateOnly: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        return f
    }()

    /// JSONDecoder configured for donkey-swift server responses.
    ///
    /// Handles ISO8601 with/without fractional seconds and date-only "YYYY-MM-DD" strings.
    /// ```swift
    /// let decoder = DonkeyDateFormatter.apiDecoder
    /// let response = try decoder.decode(SyncResponse.self, from: data)
    /// ```
    public static var apiDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = isoWithFrac.date(from: string) { return date }
            if let date = isoNoFrac.date(from: string) { return date }
            if let date = dateOnly.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date: \(string)"
            )
        }
        return decoder
    }

    /// JSONEncoder configured for donkey-swift server requests.
    ///
    /// Encodes dates as ISO8601 with fractional seconds.
    /// ```swift
    /// let encoder = DonkeyDateFormatter.apiEncoder
    /// let data = try encoder.encode(request)
    /// ```
    public static var apiEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(isoWithFrac.string(from: date))
        }
        return encoder
    }
}
