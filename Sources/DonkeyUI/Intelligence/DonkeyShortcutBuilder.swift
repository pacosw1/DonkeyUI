#if canImport(AppIntents) && !os(watchOS)
import AppIntents

/// Protocol providing default implementations for common AppIntent patterns.
public protocol DonkeyAppIntent: AppIntent {
    /// The SF Symbol icon name for this intent.
    static var iconName: String { get }
}

public extension DonkeyAppIntent {
    static var iconName: String { "star" }
}
#endif
