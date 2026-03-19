import Foundation
#if canImport(UIKit)
import StoreKit
#endif

/// Smart review prompt manager that tracks usage and only shows the review dialog
/// when meaningful engagement thresholds are met.
///
/// Usage:
/// ```swift
/// // Call on every app launch (in App.init or onAppear of root view)
/// AppReviewManager.trackAppOpen()
///
/// // Check and prompt (e.g., after a positive user action)
/// if AppReviewManager.shouldPromptForReview() {
///     AppReviewManager.requestReview()
/// }
/// ```
///
/// Thresholds are configurable:
/// ```swift
/// AppReviewManager.minimumAppOpens = 15
/// AppReviewManager.minimumDaysSinceInstall = 14
/// AppReviewManager.minimumDaysBetweenPrompts = 120
/// ```
public struct AppReviewManager {

    private init() {}

    // MARK: - Configuration

    /// Minimum number of app opens before a review prompt is eligible. Default: 10.
    public static var minimumAppOpens: Int = 10

    /// Minimum days since the app was first opened before a review prompt is eligible. Default: 7.
    public static var minimumDaysSinceInstall: Int = 7

    /// Minimum days between review prompts to avoid annoying users. Default: 90.
    public static var minimumDaysBetweenPrompts: Int = 90

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let appOpenCount = "donkeyui.review.appOpenCount"
        static let firstOpenDate = "donkeyui.review.firstOpenDate"
        static let lastPromptDate = "donkeyui.review.lastPromptDate"
    }

    private static var defaults: UserDefaults { .standard }

    // MARK: - Tracking

    /// Records an app open. Call this once per app launch.
    ///
    /// On the first call, the install date is recorded. Subsequent calls increment the open counter.
    public static func trackAppOpen() {
        // Record first open date if not set
        if defaults.object(forKey: Keys.firstOpenDate) == nil {
            defaults.set(Date(), forKey: Keys.firstOpenDate)
        }

        let current = defaults.integer(forKey: Keys.appOpenCount)
        defaults.set(current + 1, forKey: Keys.appOpenCount)
    }

    /// Determines whether the app should prompt for a review based on current thresholds.
    ///
    /// Returns `true` only when all three conditions are met:
    /// 1. App has been opened at least `minimumAppOpens` times.
    /// 2. At least `minimumDaysSinceInstall` days have passed since the first open.
    /// 3. At least `minimumDaysBetweenPrompts` days have passed since the last prompt (or never prompted).
    public static func shouldPromptForReview() -> Bool {
        let openCount = defaults.integer(forKey: Keys.appOpenCount)
        guard openCount >= minimumAppOpens else { return false }

        guard let firstOpen = defaults.object(forKey: Keys.firstOpenDate) as? Date else {
            return false
        }
        let daysSinceInstall = Calendar.current.dateComponents(
            [.day], from: firstOpen, to: Date()
        ).day ?? 0
        guard daysSinceInstall >= minimumDaysSinceInstall else { return false }

        if let lastPrompt = defaults.object(forKey: Keys.lastPromptDate) as? Date {
            let daysSincePrompt = Calendar.current.dateComponents(
                [.day], from: lastPrompt, to: Date()
            ).day ?? 0
            guard daysSincePrompt >= minimumDaysBetweenPrompts else { return false }
        }

        return true
    }

    /// Records that a review prompt was shown. Call this after presenting the review dialog.
    public static func didPromptForReview() {
        defaults.set(Date(), forKey: Keys.lastPromptDate)
    }

    /// Requests an App Store review using `SKStoreReviewController`.
    ///
    /// On iOS 16+, uses the scene-based API. On macOS, this is a no-op
    /// (macOS apps should use `SKStoreReviewController.requestReview(in:)` manually).
    ///
    /// Automatically calls `didPromptForReview()` to record the timestamp.
    public static func requestReview() {
        didPromptForReview()

        #if canImport(UIKit)
        if #available(iOS 16.0, *) {
            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })
            else { return }
            SKStoreReviewController.requestReview(in: scene)
        } else {
            SKStoreReviewController.requestReview()
        }
        #endif
    }

    // MARK: - Testing

    /// Resets all stored state. Useful for testing and development.
    public static func reset() {
        defaults.removeObject(forKey: Keys.appOpenCount)
        defaults.removeObject(forKey: Keys.firstOpenDate)
        defaults.removeObject(forKey: Keys.lastPromptDate)
    }
}
