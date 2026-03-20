//
//  DonkeyEventTracker.swift
//  Batched event tracking. Queues events, auto-flushes on timer and app background.
//  No hardcoded API — apps provide their own flush callback.
//
//  Usage:
//  1. Create:
//     let tracker = DonkeyEventTracker { events in
//         try await api.trackEvents(events)
//     }
//
//  2. Inject:
//     ContentView().environment(tracker)
//
//  3. Track:
//     tracker.track("purchase", metadata: ["product": "yearly"])
//     tracker.appOpened()
//     tracker.viewedPage("settings")
//

import Foundation
import SwiftUI
import os.log

#if canImport(UIKit)
import UIKit
#endif

private let logger = Logger(subsystem: "DonkeyUI", category: "Events")

// MARK: - Event

public struct DonkeyEvent: Sendable {
    public let event: String
    public let metadata: [String: String]
    public let timestamp: String

    public init(event: String, metadata: [String: String] = [:], timestamp: String? = nil) {
        self.event = event
        self.metadata = metadata
        self.timestamp = timestamp ?? ISO8601DateFormatter().string(from: .now)
    }
}

// MARK: - DonkeyEventTracker

@Observable
@MainActor
public final class DonkeyEventTracker {

    // MARK: - Config

    private let flushHandler: @Sendable ([DonkeyEvent]) async throws -> Void
    private let maxQueueSize: Int
    private let flushInterval: TimeInterval
    private let maxRetainedEvents: Int

    // MARK: - State

    private var queue: [DonkeyEvent] = []
    private var flushTask: Task<Void, Never>?
    private var isFlushing = false

    // Session tracking
    private var sessionID: String?
    private var sessionStart: Date?

    // MARK: - Init

    /// Create an event tracker with a custom flush handler.
    ///
    /// - Parameters:
    ///   - maxQueueSize: Flush when queue reaches this size (default: 20)
    ///   - flushInterval: Auto-flush interval in seconds (default: 30)
    ///   - maxRetainedEvents: Max events to keep on flush failure (default: 200)
    ///   - flushHandler: Your server sync function. Receives batched events.
    public init(
        maxQueueSize: Int = 20,
        flushInterval: TimeInterval = 30,
        maxRetainedEvents: Int = 200,
        flushHandler: @escaping @Sendable ([DonkeyEvent]) async throws -> Void
    ) {
        self.maxQueueSize = maxQueueSize
        self.flushInterval = flushInterval
        self.maxRetainedEvents = maxRetainedEvents
        self.flushHandler = flushHandler

        startPeriodicFlush()
        observeAppLifecycle()
    }

    // MARK: - Core

    /// Track a custom event.
    public func track(_ event: String, metadata: [String: String] = [:]) {
        queue.append(DonkeyEvent(event: event, metadata: metadata))

        if queue.count >= maxQueueSize {
            Task { await flush() }
        }
    }

    /// Flush all queued events to the server.
    public func flush() async {
        guard !queue.isEmpty, !isFlushing else { return }
        isFlushing = true
        defer { isFlushing = false }

        let batch = queue
        queue.removeAll()

        do {
            try await flushHandler(batch)
            logger.info("Flushed \(batch.count) events")
        } catch {
            // Re-queue failed events (with cap)
            queue.insert(contentsOf: batch, at: 0)
            if queue.count > maxRetainedEvents {
                queue = Array(queue.suffix(maxRetainedEvents))
            }
            logger.error("Flush failed (\(batch.count) events): \(error)")
        }
    }

    // MARK: - App Lifecycle

    /// Track app opened with device info.
    public func appOpened() {
        track("app_open", metadata: [
            "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?",
            "build": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?",
            "os": DeviceInfo.systemVersion,
            "model": DeviceInfo.modelName,
            "locale": Locale.current.identifier,
            "timezone": TimeZone.current.identifier,
            "country": Locale.current.region?.identifier ?? "",
        ])
    }

    /// Track app going to background.
    public func appBackgrounded() {
        track("app_background")
        Task { await flush() }
    }

    // MARK: - Session Tracking

    /// Start a new session. Call on app foreground.
    public func sessionStarted() -> String {
        let sid = UUID().uuidString
        sessionID = sid
        sessionStart = .now
        track("session_start", metadata: ["session_id": sid])
        return sid
    }

    /// End the current session. Call on app background.
    public func sessionEnded() {
        guard let sid = sessionID, let start = sessionStart else { return }
        let duration = Int(Date.now.timeIntervalSince(start))
        track("session_end", metadata: [
            "session_id": sid,
            "duration_s": String(duration),
        ])
        sessionID = nil
        sessionStart = nil
    }

    // MARK: - Convenience Events

    /// Track a page/screen view.
    public func viewedPage(_ page: String, metadata: [String: String] = [:]) {
        var meta = metadata
        meta["page"] = page
        track("page_view", metadata: meta)
    }

    /// Track paywall shown.
    public func paywallShown(trigger: String) {
        track("paywall_shown", metadata: ["trigger": trigger])
    }

    /// Track paywall dismissed.
    public func paywallDismissed() {
        track("paywall_dismissed")
    }

    /// Track purchase.
    public func purchased(productID: String) {
        track("purchase", metadata: ["product_id": productID])
    }

    /// Track notification permission result.
    public func notificationPermission(granted: Bool) {
        track("notification_permission", metadata: ["granted": String(granted)])
    }

    /// Track onboarding step.
    public func onboardingStep(_ step: String) {
        track("onboarding_step", metadata: ["step": step])
    }

    /// Track onboarding completed.
    public func onboardingCompleted() {
        track("onboarding_completed")
    }

    // MARK: - Private

    private func startPeriodicFlush() {
        flushTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(flushInterval))
                await flush()
            }
        }
    }

    private func observeAppLifecycle() {
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.flush()
            }
        }
        #endif
    }
}
