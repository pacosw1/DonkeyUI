//
//  DonkeySyncQueue.swift
//  Persistent sync queue with debounced batching, coalescing, and retry.
//  Queues mutations locally, flushes to server in batches. Never loses data.
//
//  Usage:
//  1. Create with a persistence store and flush handler:
//     let syncQueue = DonkeySyncQueue(
//         store: mySQLiteStore,
//         flushHandler: { items, idempotencyKey in
//             try await api.syncBatch(items: items, idempotencyKey: idempotencyKey)
//         }
//     )
//
//  2. Enqueue mutations from anywhere:
//     syncQueue.enqueue(.upsert(entityType: "habit", entityID: "abc", version: 1, fields: [...]))
//     syncQueue.enqueue(.delete(entityType: "habit", entityID: "abc"))
//
//  3. The queue handles debouncing, batching, retries, and background flush automatically.
//

import Foundation
import SwiftUI
import Combine
import os.log

#if canImport(UIKit)
import UIKit
#endif

private let logger = Logger(subsystem: "DonkeyUI", category: "SyncQueue")

// MARK: - Sync Queue Item

/// A single mutation to be synced to the server.
public struct SyncQueueItem: Sendable, Identifiable {
    public let id: String
    public let entityType: String
    public let entityID: String
    public let action: Action
    public let version: Int
    public let fields: [String: AnySendable]?
    public let createdAt: Date

    public enum Action: String, Sendable {
        case upsert
        case delete
    }

    /// Create an upsert (create or update) sync item.
    public static func upsert(
        entityType: String,
        entityID: String,
        version: Int,
        fields: [String: AnySendable]
    ) -> SyncQueueItem {
        SyncQueueItem(
            id: UUID().uuidString,
            entityType: entityType,
            entityID: entityID,
            action: .upsert,
            version: version,
            fields: fields,
            createdAt: .now
        )
    }

    /// Create a delete sync item.
    public static func delete(entityType: String, entityID: String) -> SyncQueueItem {
        SyncQueueItem(
            id: UUID().uuidString,
            entityType: entityType,
            entityID: entityID,
            action: .delete,
            version: 0,
            fields: nil,
            createdAt: .now
        )
    }
}

// MARK: - AnySendable

/// Type-erased Sendable wrapper for sync field values.
public struct AnySendable: Sendable {
    public let value: any Sendable

    public init(_ value: any Sendable) {
        self.value = value
    }
}

// MARK: - Flush Result

/// Result returned by the app's flush handler.
public struct SyncFlushResult: Sendable {
    public let succeeded: [SyncItemResult]
    public let conflicts: [SyncConflict]
    public let failed: [SyncItemFailure]

    public init(
        succeeded: [SyncItemResult] = [],
        conflicts: [SyncConflict] = [],
        failed: [SyncItemFailure] = []
    ) {
        self.succeeded = succeeded
        self.conflicts = conflicts
        self.failed = failed
    }

    /// Convenience for when the entire batch succeeds.
    public static func allSucceeded(_ items: [SyncItemResult]) -> SyncFlushResult {
        SyncFlushResult(succeeded: items)
    }
}

public struct SyncItemResult: Sendable {
    public let clientID: String
    public let serverID: String
    public let version: Int

    public init(clientID: String, serverID: String, version: Int) {
        self.clientID = clientID
        self.serverID = serverID
        self.version = version
    }
}

public struct SyncConflict: Sendable {
    public let clientID: String
    public let serverVersion: Int

    public init(clientID: String, serverVersion: Int) {
        self.clientID = clientID
        self.serverVersion = serverVersion
    }
}

public struct SyncItemFailure: Sendable {
    public let clientID: String
    public let error: String

    public init(clientID: String, error: String) {
        self.clientID = clientID
        self.error = error
    }
}

// MARK: - Persistence Store Protocol

/// Protocol for persisting sync queue items across app launches.
/// Apps implement this with their local database (SQLite, CoreData, SwiftData, etc.)
public protocol SyncQueueStore: Sendable {
    /// Save or replace a queued item. Key by (entityType, entityID) to coalesce.
    func save(_ item: SyncQueueItem) async throws

    /// Remove a successfully synced item.
    func remove(entityType: String, entityID: String) async throws

    /// Load all pending items, ordered by createdAt.
    func loadAll() async throws -> [SyncQueueItem]

    /// Remove all items (e.g. on sign out).
    func removeAll() async throws
}

// MARK: - Conflict Resolver Protocol

/// Optional protocol for apps to provide custom conflict resolution.
/// If not provided, conflicts are re-enqueued with the server version (last-write-wins).
public protocol SyncConflictResolver: Sendable {
    /// Resolve a conflict. Return a new item to re-enqueue, or nil to drop it.
    func resolve(
        item: SyncQueueItem,
        serverVersion: Int
    ) async -> SyncQueueItem?
}

// MARK: - DonkeySyncQueue

@Observable
@MainActor
public final class DonkeySyncQueue {

    // MARK: - Config

    private let store: SyncQueueStore
    private let flushHandler: @Sendable ([SyncQueueItem], String) async throws -> SyncFlushResult
    private let conflictResolver: SyncConflictResolver?
    private let debounceInterval: TimeInterval
    private let maxWaitInterval: TimeInterval
    private let maxBatchSize: Int
    private let maxRetryAttempts: Int
    private let baseRetryDelay: TimeInterval

    // MARK: - Observable State

    /// Current sync state for UI binding.
    public private(set) var state: SyncState = .idle

    /// Number of pending items in the queue.
    public private(set) var pendingCount: Int = 0

    // MARK: - Internal State

    /// In-memory queue, coalesced by entity key.
    private var queue: [String: SyncQueueItem] = [:]
    private var debounceTask: Task<Void, Never>?
    private var maxWaitTask: Task<Void, Never>?
    private var retryTask: Task<Void, Never>?
    private var isFlushing = false
    private var retryAttempt = 0
    private var networkCancellable: AnyCancellable?

    // MARK: - Init

    /// Create a sync queue.
    ///
    /// - Parameters:
    ///   - store: Persistent storage for queue items (survives app kill).
    ///   - debounceInterval: Seconds to wait after last enqueue before flushing (default: 30).
    ///   - maxWaitInterval: Max seconds before forcing a flush regardless of activity (default: 120).
    ///   - maxBatchSize: Max items per server request (default: 500, matches server limit).
    ///   - maxRetryAttempts: Max retry attempts on network failure (default: 10).
    ///   - baseRetryDelay: Base delay for exponential backoff in seconds (default: 5).
    ///   - conflictResolver: Optional custom conflict resolver. Defaults to last-write-wins.
    ///   - flushHandler: Your server sync function. Receives batch items and an idempotency key.
    public init(
        store: SyncQueueStore,
        debounceInterval: TimeInterval = 30,
        maxWaitInterval: TimeInterval = 120,
        maxBatchSize: Int = 500,
        maxRetryAttempts: Int = 10,
        baseRetryDelay: TimeInterval = 5,
        conflictResolver: SyncConflictResolver? = nil,
        flushHandler: @escaping @Sendable ([SyncQueueItem], String) async throws -> SyncFlushResult
    ) {
        self.store = store
        self.debounceInterval = debounceInterval
        self.maxWaitInterval = maxWaitInterval
        self.maxBatchSize = maxBatchSize
        self.maxRetryAttempts = maxRetryAttempts
        self.baseRetryDelay = baseRetryDelay
        self.conflictResolver = conflictResolver
        self.flushHandler = flushHandler

        Task { await loadPersistedQueue() }
        observeAppLifecycle()
        observeNetworkRestore()
    }

    // MARK: - Public API

    /// Enqueue a mutation. Coalesces with any pending mutation for the same entity.
    public func enqueue(_ item: SyncQueueItem) {
        let key = "\(item.entityType):\(item.entityID)"

        // Coalesce: if there's a pending create and this is a delete, cancel both
        if item.action == .delete, let existing = queue[key], existing.version == 0 {
            queue.removeValue(forKey: key)
            Task {
                try? await store.remove(entityType: item.entityType, entityID: item.entityID)
            }
            pendingCount = queue.count
            logger.debug("Create+delete cancelled out for \(key)")
            return
        }

        queue[key] = item
        pendingCount = queue.count

        // Persist
        Task { try? await store.save(item) }

        // Reset debounce timer
        resetDebounce()

        // Reset retry state on new user activity
        retryAttempt = 0
        retryTask?.cancel()
        retryTask = nil

        logger.debug("Enqueued \(item.action.rawValue) for \(key) (pending: \(self.pendingCount))")
    }

    /// Immediately flush all pending items. Called by app on background, foreground, pull-to-refresh, etc.
    public func flush() async {
        guard !queue.isEmpty, !isFlushing else { return }

        debounceTask?.cancel()
        maxWaitTask?.cancel()
        maxWaitTask = nil
        isFlushing = true

        let items = Array(queue.values).sorted { $0.createdAt < $1.createdAt }
        let chunks = Self.chunk(items, into: maxBatchSize)

        let total = items.count
        var completed = 0

        state = .syncing(progress: 0, completed: 0, total: total)

        for chunk in chunks {
            let idempotencyKey = UUID().uuidString

            do {
                let result = try await flushHandler(chunk, idempotencyKey)

                // Remove succeeded items
                for item in result.succeeded {
                    if let queueItem = chunk.first(where: { $0.id == item.clientID }) {
                        let key = "\(queueItem.entityType):\(queueItem.entityID)"
                        queue.removeValue(forKey: key)
                        try? await store.remove(entityType: queueItem.entityType, entityID: queueItem.entityID)
                    }
                }

                // Handle conflicts
                for conflict in result.conflicts {
                    if let queueItem = chunk.first(where: { $0.id == conflict.clientID }) {
                        let key = "\(queueItem.entityType):\(queueItem.entityID)"
                        queue.removeValue(forKey: key)

                        if let resolver = conflictResolver {
                            if let resolved = await resolver.resolve(item: queueItem, serverVersion: conflict.serverVersion) {
                                queue[key] = resolved
                                try? await store.save(resolved)
                            } else {
                                try? await store.remove(entityType: queueItem.entityType, entityID: queueItem.entityID)
                            }
                        } else {
                            // Default: last-write-wins — re-enqueue with server version
                            let resolved = SyncQueueItem(
                                id: UUID().uuidString,
                                entityType: queueItem.entityType,
                                entityID: queueItem.entityID,
                                action: queueItem.action,
                                version: conflict.serverVersion,
                                fields: queueItem.fields,
                                createdAt: .now
                            )
                            queue[key] = resolved
                            try? await store.save(resolved)
                        }
                    }
                }

                // Failed items stay in queue for retry
                completed += chunk.count
                let progress = Double(completed) / Double(total)
                state = .syncing(progress: progress, completed: completed, total: total)
                retryAttempt = 0

            } catch {
                // Network error — items stay in queue, schedule retry
                logger.error("Flush failed: \(error.localizedDescription)")
                isFlushing = false
                pendingCount = queue.count
                state = .error(message: "Sync failed: \(error.localizedDescription)", lastSynced: nil)
                scheduleRetry()
                return
            }
        }

        isFlushing = false
        pendingCount = queue.count

        if queue.isEmpty {
            state = .upToDate(lastSynced: .now)
            logger.info("Sync complete — all items flushed")
        } else {
            // Conflicts were re-enqueued — flush again after debounce
            logger.info("Sync partial — \(self.pendingCount) items re-enqueued (conflicts)")
            resetDebounce()
        }
    }

    /// Clear the queue (e.g. on sign out).
    public func clear() async {
        debounceTask?.cancel()
        maxWaitTask?.cancel()
        retryTask?.cancel()
        queue.removeAll()
        pendingCount = 0
        state = .idle
        try? await store.removeAll()
    }

    // MARK: - Debounce

    private func resetDebounce() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(for: .seconds(debounceInterval))
            guard !Task.isCancelled else { return }
            // Launch flush in an independent task so cancelling the debounce
            // timer (e.g. from a new enqueue) doesn't cancel an in-flight flush.
            Task { await flush() }
        }

        // Start max-wait timer on first item if not running
        if maxWaitTask == nil {
            maxWaitTask = Task {
                try? await Task.sleep(for: .seconds(maxWaitInterval))
                guard !Task.isCancelled else { return }
                Task { await flush() }
            }
        }
    }

    // MARK: - Retry

    private func scheduleRetry() {
        guard retryAttempt < maxRetryAttempts else {
            state = .error(message: "Sync failed after \(maxRetryAttempts) attempts. Pull to retry.", lastSynced: nil)
            logger.error("Max retry attempts reached (\(self.maxRetryAttempts))")
            return
        }

        retryAttempt += 1

        // Exponential backoff with jitter: base * 2^attempt + random jitter
        let delay = baseRetryDelay * pow(2.0, Double(retryAttempt - 1))
        let capped = min(delay, 300) // Cap at 5 minutes
        let jitter = Double.random(in: 0...(capped * 0.2))
        let totalDelay = capped + jitter

        logger.info("Retry \(self.retryAttempt)/\(self.maxRetryAttempts) in \(Int(totalDelay))s")

        retryTask = Task {
            try? await Task.sleep(for: .seconds(totalDelay))
            guard !Task.isCancelled else { return }

            // Only retry if we have network
            guard await MainActor.run(body: { NetworkMonitor.shared.isConnected }) else {
                logger.info("No network — deferring retry until connectivity restored")
                return
            }

            Task { await flush() }
        }
    }

    // MARK: - Lifecycle & Network

    private func observeAppLifecycle() {
        #if canImport(UIKit)
        // Flush on background
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.flush()
            }
        }

        // Flush on foreground (catch up after sleep)
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.flush()
            }
        }
        #endif
    }

    private func observeNetworkRestore() {
        // When network comes back, flush pending items
        var wasDisconnected = false
        networkCancellable = NetworkMonitor.shared.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                guard let self else { return }
                if !connected {
                    wasDisconnected = true
                } else if wasDisconnected {
                    wasDisconnected = false
                    logger.info("Network restored — flushing queue")
                    Task { @MainActor in
                        await self.flush()
                    }
                }
            }
    }

    // MARK: - Persistence

    private func loadPersistedQueue() async {
        do {
            let items = try await store.loadAll()
            for item in items {
                let key = "\(item.entityType):\(item.entityID)"
                queue[key] = item
            }
            pendingCount = queue.count
            if !queue.isEmpty {
                logger.info("Loaded \(self.pendingCount) persisted sync items")
                resetDebounce()
            }
        } catch {
            logger.error("Failed to load persisted queue: \(error.localizedDescription)")
        }
    }
}

// MARK: - Array Chunking (scoped to avoid redeclaration)

extension DonkeySyncQueue {
    fileprivate static func chunk<T>(_ array: [T], into size: Int) -> [[T]] {
        guard size > 0 else { return [array] }
        return stride(from: 0, to: array.count, by: size).map {
            Array(array[$0..<Swift.min($0 + size, array.count)])
        }
    }
}
