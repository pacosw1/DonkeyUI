import Foundation
import os.log

private let logger = Logger(subsystem: "DonkeyUI", category: "Session")

@Observable
@MainActor
public final class DonkeySessionTracker {
    public private(set) var sessionCount: Int
    public private(set) var currentSessionStart: Date?
    public private(set) var totalForegroundTime: TimeInterval

    /// Current session duration (0 if no active session)
    public var currentSessionDuration: TimeInterval {
        guard let start = currentSessionStart else { return 0 }
        return Date().timeIntervalSince(start)
    }

    /// True on the very first session
    public var isFirstSession: Bool { sessionCount <= 1 }

    /// Days since first app launch
    public var daysSinceInstall: Int {
        guard let firstLaunch = defaults.object(forKey: firstLaunchKey) as? Date else { return 0 }
        return Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
    }

    private let defaults: UserDefaults
    private let keyPrefix: String

    private var sessionCountKey: String { "\(keyPrefix).count" }
    private var totalTimeKey: String { "\(keyPrefix).totalTime" }
    private var firstLaunchKey: String { "\(keyPrefix).firstLaunch" }

    public init(suite: String? = nil, keyPrefix: String = "donkeyui.session") {
        self.defaults = suite.flatMap { UserDefaults(suiteName: $0) } ?? .standard
        self.keyPrefix = keyPrefix
        self.sessionCount = defaults.integer(forKey: "\(keyPrefix).count")
        self.totalForegroundTime = defaults.double(forKey: "\(keyPrefix).totalTime")

        if defaults.object(forKey: "\(keyPrefix).firstLaunch") == nil {
            defaults.set(Date(), forKey: "\(keyPrefix).firstLaunch")
        }
    }

    /// Call when app enters foreground.
    public func sessionStarted() {
        sessionCount += 1
        defaults.set(sessionCount, forKey: sessionCountKey)
        currentSessionStart = Date()
        logger.debug("Session #\(self.sessionCount) started")
    }

    /// Call when app enters background.
    public func sessionEnded() {
        if let start = currentSessionStart {
            let duration = Date().timeIntervalSince(start)
            totalForegroundTime += duration
            defaults.set(totalForegroundTime, forKey: totalTimeKey)
            logger.debug("Session ended after \(Int(duration))s")
        }
        currentSessionStart = nil
    }
}
