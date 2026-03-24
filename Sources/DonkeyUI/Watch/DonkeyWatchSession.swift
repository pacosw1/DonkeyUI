//
//  DonkeyWatchSession.swift
//  DonkeyUI
//
//  Watch-side WatchConnectivity session manager.
//  Handles WCSession lifecycle, reachability tracking, deduplication, and message sending.

#if canImport(WatchConnectivity) && os(watchOS)
import Combine
import Foundation
import WatchConnectivity

/// Delegate that handles incoming data from the iPhone.
public protocol DonkeyWatchSessionDelegate: AnyObject {
    /// Called when new data arrives from the iPhone (via applicationContext or message).
    /// Implement this to update your watch app's state.
    func watchSessionDidReceiveData(_ data: [String: Any])
}

/// Reusable watch-side WatchConnectivity manager.
///
/// Tracks reachability, deduplicates updates by timestamp, and provides
/// helpers for sending messages to the iPhone.
/// ```swift
/// let session = DonkeyWatchSession.shared
/// session.delegate = self
/// session.requestSync()
/// ```
public final class DonkeyWatchSession: NSObject, ObservableObject, WCSessionDelegate {
    public static let shared = DonkeyWatchSession()

    /// Whether the iPhone is currently reachable.
    @Published public var isReachable = false

    public weak var delegate: DonkeyWatchSessionDelegate?

    private var lastAppliedTimestamp: Double = 0

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Public API

    /// Send a message to the iPhone. Returns `true` if the iPhone is reachable and the message was dispatched.
    @discardableResult
    public func sendMessage(_ message: [String: Any], errorHandler: ((Error) -> Void)? = nil) -> Bool {
        guard WCSession.default.isReachable else { return false }
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: errorHandler)
        return true
    }

    /// Send a message to the iPhone and receive a reply.
    /// Returns `nil` if the iPhone is not reachable.
    public func sendMessage(_ message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void, errorHandler: ((Error) -> Void)? = nil) -> Bool {
        guard WCSession.default.isReachable else { return false }
        WCSession.default.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
        return true
    }

    /// Request a sync from the iPhone. Sends `["request": "sync"]`.
    /// Override the message by passing a custom dictionary.
    public func requestSync(message: [String: Any] = ["request": "sync"]) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(message, replyHandler: { [weak self] reply in
            self?.applyData(reply)
        }, errorHandler: { error in
            print("[DonkeyWatch] Sync request failed: \(error.localizedDescription)")
        })
    }

    // MARK: - Internal

    private func applyData(_ data: [String: Any]) {
        let timestamp = data["timestamp"] as? Double ?? 0
        if timestamp > 0 && timestamp == lastAppliedTimestamp { return }
        lastAppliedTimestamp = timestamp

        delegate?.watchSessionDidReceiveData(data)
    }

    // MARK: - WCSessionDelegate

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        if activationState == .activated {
            let ctx = session.receivedApplicationContext
            if !ctx.isEmpty {
                applyData(ctx)
            } else {
                requestSync()
            }
        }
    }

    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        applyData(applicationContext)
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        applyData(message)
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        applyData(message)
    }

    public func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        if session.isReachable {
            requestSync()
        }
    }
}
#endif
