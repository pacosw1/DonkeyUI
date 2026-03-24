//
//  DonkeyPhoneSession.swift
//  DonkeyUI
//
//  iPhone-side WatchConnectivity session manager.
//  Handles WCSession lifecycle, throttled context pushes, and message routing.

#if canImport(WatchConnectivity) && os(iOS)
import Foundation
import WatchConnectivity

/// Delegate that provides app-specific data and handles incoming watch messages.
public protocol DonkeyPhoneSessionDelegate: AnyObject {
    /// Build the context dictionary to push to the watch.
    /// Called by `syncToWatch()`. Include any data the watch needs (tokens, state, etc.).
    func phoneSessionBuildContext() -> [String: Any]

    /// Handle a message received from the watch.
    /// - Parameters:
    ///   - message: The message dictionary sent by the watch.
    ///   - replyHandler: Optional reply handler — call it to send data back. Nil for fire-and-forget messages.
    func phoneSessionDidReceiveMessage(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)?)
}

/// Reusable iPhone-side WatchConnectivity manager.
///
/// Subclass or use with a delegate to provide app-specific sync data.
/// ```swift
/// let session = DonkeyPhoneSession.shared
/// session.delegate = self
/// session.syncToWatch()
/// ```
public final class DonkeyPhoneSession: NSObject, WCSessionDelegate {
    public static let shared = DonkeyPhoneSession()

    public weak var delegate: DonkeyPhoneSessionDelegate?

    /// Minimum interval between syncs (seconds). Defaults to 1.
    public var throttleInterval: TimeInterval = 1

    private var lastSyncTime: Date = .distantPast

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Public API

    /// Push current app state to the watch via `updateApplicationContext`.
    /// Throttled to `throttleInterval`. Asks delegate for the context dictionary.
    public func syncToWatch() {
        guard Date.now.timeIntervalSince(lastSyncTime) > throttleInterval else { return }
        lastSyncTime = .now

        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated,
              WCSession.default.isPaired else { return }

        guard let context = delegate?.phoneSessionBuildContext() else { return }

        var payload = context
        payload["timestamp"] = Date.now.timeIntervalSince1970

        try? WCSession.default.updateApplicationContext(payload)
    }

    /// Whether the watch is currently paired and the session is activated.
    public var isPaired: Bool {
        WCSession.isSupported() && WCSession.default.isPaired
    }

    /// Whether the watch app is reachable right now.
    public var isReachable: Bool {
        WCSession.isSupported() && WCSession.default.isReachable
    }

    // MARK: - WCSessionDelegate

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            syncToWatch()
        }
    }

    public func sessionDidBecomeInactive(_ session: WCSession) {}

    public func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        delegate?.phoneSessionDidReceiveMessage(message, replyHandler: nil)
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        delegate?.phoneSessionDidReceiveMessage(message, replyHandler: replyHandler)
    }
}
#endif
