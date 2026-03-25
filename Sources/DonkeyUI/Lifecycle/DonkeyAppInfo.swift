import Foundation

public struct DonkeyAppInfo {
    private init() {}

    /// Bundle identifier (e.g., "com.example.myapp")
    public static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "unknown"
    }

    /// Display name from Info.plist
    public static var displayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        ?? "Unknown"
    }

    /// Marketing version (e.g., "1.2.3")
    public static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
    }

    /// Build number (e.g., "42")
    public static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
    }

    /// Formatted "1.2.3 (42)" string
    public static var formattedVersion: String {
        "\(version) (\(buildNumber))"
    }

    /// True if running in DEBUG configuration
    public static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// True if running in TestFlight
    public static var isTestFlight: Bool {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }

    /// True if running in App Store (not TestFlight, not simulator, not debug)
    public static var isAppStore: Bool {
        !isDebug && !isTestFlight
    }
}
