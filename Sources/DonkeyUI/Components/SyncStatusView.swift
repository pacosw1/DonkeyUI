//
//  SyncStatusView.swift
//  Generic cloud sync status view. Shows sync state, storage, item counts, and actions.
//  Apps provide data through SyncStatusData — no hardcoded sync service.
//
//  Usage:
//  SyncStatusView(
//      data: mySyncData,
//      onSync: { await syncService.sync() },
//      onFullSync: { await syncService.fullSync() },
//      onUpgrade: { showPaywall = true }
//  )
//

import SwiftUI

// MARK: - Data Models

/// Current sync state.
public enum SyncState: Sendable {
    case idle
    case syncing(progress: Double, completed: Int, total: Int)
    case upToDate(lastSynced: Date)
    case error(message: String, lastSynced: Date?)
}

/// A tracked item category with count and optional limit.
public struct SyncItemCount: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let systemIcon: String
    public let count: Int
    public let limit: Int?

    public init(id: String = UUID().uuidString, label: String, systemIcon: String, count: Int, limit: Int? = nil) {
        self.id = id
        self.label = label
        self.systemIcon = systemIcon
        self.count = count
        self.limit = limit
    }
}

/// Storage usage info.
public struct SyncStorageInfo: Sendable {
    public let usedBytes: Int
    public let limitBytes: Int
    public let tier: String
    public let tierLabel: String

    public init(usedBytes: Int, limitBytes: Int, tier: String = "free", tierLabel: String = "Free") {
        self.usedBytes = usedBytes
        self.limitBytes = limitBytes
        self.tier = tier
        self.tierLabel = tierLabel
    }

    public var usageRatio: Double {
        guard limitBytes > 0 else { return 0 }
        return min(Double(usedBytes) / Double(limitBytes), 1.0)
    }
}

/// All data needed by SyncStatusView.
public struct SyncStatusData {
    public let state: SyncState
    public let storage: SyncStorageInfo?
    public let items: [SyncItemCount]
    public let userLabel: String?

    public init(
        state: SyncState,
        storage: SyncStorageInfo? = nil,
        items: [SyncItemCount] = [],
        userLabel: String? = nil
    ) {
        self.state = state
        self.storage = storage
        self.items = items
        self.userLabel = userLabel
    }
}

// MARK: - SyncStatusView

public struct SyncStatusView: View {
    let data: SyncStatusData
    let onSync: (() async -> Void)?
    let onFullSync: (() async -> Void)?
    let onUpgrade: (() -> Void)?

    @Environment(\.donkeyTheme) var theme

    public init(
        data: SyncStatusData,
        onSync: (() async -> Void)? = nil,
        onFullSync: (() async -> Void)? = nil,
        onUpgrade: (() -> Void)? = nil
    ) {
        self.data = data
        self.onSync = onSync
        self.onFullSync = onFullSync
        self.onUpgrade = onUpgrade
    }

    private var isSyncing: Bool {
        if case .syncing = data.state { return true }
        return false
    }

    public var body: some View {
        Form {
            statusSection
            if let storage = data.storage { storageSection(storage) }
            if !data.items.isEmpty { itemCountsSection }
            actionsSection
        }
        .formStyle(.grouped)
    }

    // MARK: - Status Section

    private var statusSection: some View {
        Section("Status") {
            HStack(spacing: 12) {
                statusIcon
                VStack(alignment: .leading, spacing: 2) {
                    Text(statusTitle)
                        .font(theme.typography.headline)
                    Text(statusSubtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.secondary)
                }
                Spacer()
            }

            if case .syncing(let progress, let completed, let total) = data.state, total > 0 {
                VStack(alignment: .leading, spacing: 6) {
                    ProgressView(value: progress)
                        .tint(theme.colors.accent)
                    Text("Syncing \(completed) of \(total) items...")
                        .font(theme.typography.caption2)
                        .foregroundStyle(theme.colors.secondary)
                }
            }

            if case .error(let message, _) = data.state {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(theme.colors.warning)
                        .font(theme.typography.caption)
                    Text(message)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch data.state {
        case .syncing:
            ProgressView()
                .frame(width: 32, height: 32)
        case .error:
            Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                .font(.system(size: 24))
                .foregroundStyle(theme.colors.warning)
        case .upToDate:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(theme.colors.success)
        case .idle:
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 24))
                .foregroundStyle(theme.colors.accent)
        }
    }

    private var statusTitle: String {
        switch data.state {
        case .syncing: return "Syncing..."
        case .error: return "Sync Error"
        case .upToDate: return "Up to Date"
        case .idle: return "Cloud Sync"
        }
    }

    private var statusSubtitle: String {
        switch data.state {
        case .syncing: return "Uploading changes to server"
        case .error(_, let lastSynced):
            if let date = lastSynced {
                return "Last synced \(date.formatted(.relative(presentation: .named)))"
            }
            return "Unable to sync"
        case .upToDate(let date):
            return "Last synced \(date.formatted(.relative(presentation: .named)))"
        case .idle: return "Connected"
        }
    }

    // MARK: - Storage Section

    private func storageSection(_ storage: SyncStorageInfo) -> some View {
        Section("Storage") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Storage Used")
                        .font(theme.typography.subheadline)
                    Spacer()
                    Text(formatBytes(storage.usedBytes))
                        .font(theme.typography.subheadline)
                        .foregroundStyle(theme.colors.secondary)
                    Text("/ \(formatBytes(storage.limitBytes))")
                        .font(theme.typography.subheadline)
                        .foregroundStyle(theme.colors.secondary.opacity(0.6))
                }

                ProgressView(value: storage.usageRatio)
                    .tint(storageColor(storage.usageRatio))

                HStack {
                    StatusBadge(
                        label: storage.tierLabel.uppercased(),
                        style: storage.tier == "free" ? .expired : .active
                    )
                    Spacer()
                    if storage.tier == "free", let onUpgrade {
                        Button("Upgrade") { onUpgrade() }
                            .font(theme.typography.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    private func storageColor(_ ratio: Double) -> Color {
        if ratio > 0.9 { return theme.colors.error }
        if ratio > 0.7 { return theme.colors.warning }
        return theme.colors.accent
    }

    // MARK: - Item Counts Section

    private var itemCountsSection: some View {
        Section("Synced Items") {
            ForEach(data.items) { item in
                HStack {
                    Image(systemName: item.systemIcon)
                        .foregroundStyle(theme.colors.secondary)
                        .frame(width: 24)
                    Text(item.label)
                        .font(theme.typography.subheadline)
                    Spacer()
                    if let limit = item.limit {
                        Text("\(item.count)")
                            .fontWeight(.medium)
                            .foregroundStyle(item.count >= limit ? theme.colors.error : theme.colors.onSurface)
                        Text("/ \(limit)")
                            .foregroundStyle(theme.colors.secondary.opacity(0.6))
                            .font(theme.typography.caption)
                    } else {
                        Text("\(item.count)")
                            .fontWeight(.medium)
                            .foregroundStyle(theme.colors.secondary)
                    }
                }
                .font(theme.typography.subheadline)
            }
        }
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        Section {
            if let onSync {
                Button {
                    Task { await onSync() }
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Sync Now")
                    }
                }
                .disabled(isSyncing)
            }

            if let onFullSync {
                Button {
                    Task { await onFullSync() }
                } label: {
                    HStack {
                        Image(systemName: "arrow.2.squarepath")
                        Text("Full Sync")
                    }
                }
                .disabled(isSyncing)
            }
        } footer: {
            if let user = data.userLabel {
                Text("Signed in as \(user)")
                    .font(theme.typography.caption2)
            }
        }
    }

    // MARK: - Helpers

    private func formatBytes(_ bytes: Int) -> String {
        let mb = Double(bytes) / (1024.0 * 1024.0)
        if mb < 1 {
            return String(format: "%.0f KB", Double(bytes) / 1024.0)
        }
        if mb >= 1024 {
            return String(format: "%.1f GB", mb / 1024.0)
        }
        return String(format: "%.1f MB", mb)
    }
}

// MARK: - Compact Sync Row (for settings list)

/// A compact sync status row for use in settings lists. Shows dot + label + last synced.
public struct SyncStatusRow: View {
    let state: SyncState
    let onTap: (() -> Void)?

    @Environment(\.donkeyTheme) var theme

    public init(state: SyncState, onTap: (() -> Void)? = nil) {
        self.state = state
        self.onTap = onTap
    }

    public var body: some View {
        HStack(spacing: 12) {
            statusDot
            VStack(alignment: .leading, spacing: 2) {
                Text("Cloud Sync")
                    .font(theme.typography.subheadline)
                subtitleView
            }
            Spacer()
            if case .syncing = state {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }

    @ViewBuilder
    private var statusDot: some View {
        switch state {
        case .syncing:
            ProgressView()
                .scaleEffect(0.6)
                .frame(width: 10, height: 10)
        case .error:
            Circle().fill(Color.orange).frame(width: 8, height: 8)
        case .upToDate:
            Circle().fill(Color.green).frame(width: 8, height: 8)
        case .idle:
            Circle().fill(theme.colors.secondary).frame(width: 8, height: 8)
        }
    }

    @ViewBuilder
    private var subtitleView: some View {
        switch state {
        case .syncing:
            Text("Syncing...")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.secondary)
        case .error(let msg, _):
            Text(msg)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.warning)
        case .upToDate(let date):
            Text("Last synced \(date.formatted(.relative(presentation: .named)))")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.secondary)
        case .idle:
            Text("Tap to view details")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.secondary)
        }
    }
}

// MARK: - Preview

#Preview("Full Sync View") {
    NavigationStack {
        SyncStatusView(
            data: SyncStatusData(
                state: .upToDate(lastSynced: Date().addingTimeInterval(-300)),
                storage: SyncStorageInfo(usedBytes: 3_500_000, limitBytes: 10_485_760, tier: "free", tierLabel: "Free"),
                items: [
                    SyncItemCount(label: "Tasks", systemIcon: "checkmark.circle", count: 42, limit: 100),
                    SyncItemCount(label: "Completed", systemIcon: "checkmark.circle.fill", count: 156),
                    SyncItemCount(label: "Lists", systemIcon: "list.bullet", count: 5, limit: 10),
                    SyncItemCount(label: "Tags", systemIcon: "tag", count: 8, limit: 20),
                ],
                userLabel: "paco@example.com"
            ),
            onSync: {},
            onFullSync: {},
            onUpgrade: {}
        )
        .navigationTitle("Cloud Sync")
    }
}

#Preview("Syncing") {
    NavigationStack {
        SyncStatusView(
            data: SyncStatusData(
                state: .syncing(progress: 0.6, completed: 24, total: 40)
            ),
            onSync: {},
            onFullSync: {}
        )
        .navigationTitle("Cloud Sync")
    }
}

#Preview("Compact Row") {
    List {
        SyncStatusRow(state: .upToDate(lastSynced: .now.addingTimeInterval(-60)))
        SyncStatusRow(state: .syncing(progress: 0.5, completed: 10, total: 20))
        SyncStatusRow(state: .error(message: "Connection failed", lastSynced: nil))
        SyncStatusRow(state: .idle)
    }
}
