//
//  DonkeySyncChangeTracker.swift
//  Tracks local DB mutations, debounces + coalesces them, then flushes to a callback.
//  Sits between your local database writes and DonkeySyncQueue to prevent
//  echo-back from server pulls and collapse rapid edits into minimal sync items.
//
//  Usage:
//  1. Create with a flush callback:
//     let tracker = DonkeySyncChangeTracker(debounceInterval: 1.5) { inserts, updates, deletes in
//         for (type, id) in inserts { syncQueue.enqueue(.upsert(entityType: type, entityID: id.uuidString, ...)) }
//         for (type, id) in updates { syncQueue.enqueue(.upsert(entityType: type, entityID: id.uuidString, ...)) }
//         for (type, id) in deletes { syncQueue.enqueue(.delete(entityType: type, entityID: id.uuidString)) }
//     }
//
//  2. Record changes from your DB write methods:
//     tracker.recordChange("task", id: taskUUID, action: .insert)
//
//  3. Suppress during server pull application:
//     tracker.suppress()
//     applyServerChanges()
//     tracker.unsuppress()
//
//  4. Flush immediately on app background:
//     tracker.flushImmediately()
//
//  Coalescing rules:
//  - insert → update  = insert (still new, send full create)
//  - insert → delete  = no-op  (never existed on server)
//  - update → delete  = delete (just remove it)
//  - delete → insert  = update (re-created with same ID)
//  - same action repeated = latest wins
//

import Foundation
import os.log

#if canImport(UIKit)
import UIKit
#endif

private let logger = Logger(subsystem: "DonkeyUI", category: "SyncChangeTracker")

// MARK: - Change Action

/// The type of local mutation that occurred.
public enum SyncChangeAction: Sendable {
    case insert
    case update
    case delete
}

// MARK: - Flush Callback

/// Callback invoked when coalesced changes are ready to push.
/// Parameters: (inserts, updates, deletes) — each is an array of (entityType, entityID).
public typealias SyncChangeFlushHandler = @MainActor (
    _ inserts: [(String, UUID)],
    _ updates: [(String, UUID)],
    _ deletes: [(String, UUID)]
) -> Void

// MARK: - DonkeySyncChangeTracker

/// Accumulates local DB changes with debouncing and intelligent coalescing,
/// then flushes them to a callback for sync queue ingestion.
@Observable
@MainActor
public final class DonkeySyncChangeTracker {

    // MARK: - Config

    private let debounceInterval: TimeInterval
    private let flushHandler: SyncChangeFlushHandler

    // MARK: - State

    private var pendingChanges: [(String, UUID, SyncChangeAction)] = []
    private var flushTask: Task<Void, Never>?

    /// When true, changes are silently ignored. Set during server pull application
    /// to prevent server-originated writes from bouncing back as pushes.
    private var isSuppressed = false

    // MARK: - Init

    /// Create a change tracker.
    ///
    /// - Parameters:
    ///   - debounceInterval: Seconds to wait after the last change before flushing (default: 1.5).
    ///   - flushHandler: Called with coalesced (inserts, updates, deletes) when the debounce fires.
    public init(
        debounceInterval: TimeInterval = 1.5,
        flushHandler: @escaping SyncChangeFlushHandler
    ) {
        self.debounceInterval = debounceInterval
        self.flushHandler = flushHandler
        observeAppLifecycle()
    }

    // MARK: - Public API

    /// Record a local change that should eventually be pushed to the server.
    /// Call this from every local database write method (insert, update, delete).
    public func recordChange(_ entityType: String, id: UUID, action: SyncChangeAction) {
        guard !isSuppressed else { return }
        pendingChanges.append((entityType, id, action))
        scheduleFlush()
    }

    /// Record multiple changes at once (e.g. batch operations).
    public func recordChanges(_ changes: [(String, UUID, SyncChangeAction)]) {
        guard !isSuppressed else { return }
        pendingChanges.append(contentsOf: changes)
        scheduleFlush()
    }

    /// Suppress change tracking. Call before applying server pull responses
    /// so that server-originated writes don't trigger a push back.
    public func suppress() {
        isSuppressed = true
    }

    /// Re-enable change tracking after server pull application is complete.
    public func unsuppress() {
        isSuppressed = false
    }

    /// Force an immediate flush, bypassing the debounce timer.
    /// Call when the app is about to go to background.
    public func flushImmediately() {
        flushTask?.cancel()
        flushTask = nil
        flush()
    }

    // MARK: - Debounce

    private func scheduleFlush() {
        flushTask?.cancel()
        flushTask = Task {
            try? await Task.sleep(for: .seconds(debounceInterval))
            guard !Task.isCancelled else { return }
            flush()
        }
    }

    // MARK: - Flush & Coalesce

    private func flush() {
        let changes = pendingChanges
        pendingChanges = []
        flushTask = nil
        guard !changes.isEmpty else { return }

        // Coalesce changes per (entityType, id) — later actions override earlier ones,
        // with special handling for cancellation pairs.
        var coalesced: [String: (String, UUID, SyncChangeAction)] = [:]

        for (entityType, id, action) in changes {
            let key = "\(entityType):\(id.uuidString)"

            if let existing = coalesced[key] {
                switch (existing.2, action) {
                case (.insert, .update):
                    // Inserted then updated in same batch — still an insert
                    coalesced[key] = (entityType, id, .insert)
                case (.insert, .delete):
                    // Inserted then deleted — cancel out entirely (never reached server)
                    coalesced.removeValue(forKey: key)
                case (.update, .delete):
                    // Updated then deleted — just delete
                    coalesced[key] = (entityType, id, .delete)
                case (.delete, .insert):
                    // Deleted then re-inserted — treat as update (re-created with same ID)
                    coalesced[key] = (entityType, id, .update)
                default:
                    // Same action repeated, or any other combo — latest wins
                    coalesced[key] = (entityType, id, action)
                }
            } else {
                coalesced[key] = (entityType, id, action)
            }
        }

        guard !coalesced.isEmpty else { return }

        // Group by action
        var inserts: [(String, UUID)] = []
        var updates: [(String, UUID)] = []
        var deletes: [(String, UUID)] = []

        for (_, (entityType, id, action)) in coalesced {
            switch action {
            case .insert: inserts.append((entityType, id))
            case .update: updates.append((entityType, id))
            case .delete: deletes.append((entityType, id))
            }
        }

        logger.debug("Flushing: \(inserts.count) inserts, \(updates.count) updates, \(deletes.count) deletes")
        flushHandler(inserts, updates, deletes)
    }

    // MARK: - Lifecycle

    private func observeAppLifecycle() {
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.flushImmediately()
            }
        }
        #endif
    }
}
