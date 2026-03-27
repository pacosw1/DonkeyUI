//
//  SyncIndicatorView.swift
//  Compact toolbar sync status indicator. Shows an icon only when
//  offline, syncing, or on error — invisible when up to date.
//
//  Usage:
//  ```swift
//  NavigationStack {
//      ContentView()
//          .toolbar {
//              ToolbarItem(placement: .topBarTrailing) {
//                  SyncIndicatorView(state: syncQueue.state, isConnected: network.isConnected)
//              }
//          }
//  }
//  ```
//

import SwiftUI

/// Compact sync status icon for toolbars and navigation bars.
/// Only visible when there's something to show (offline, syncing, or error).
public struct SyncIndicatorView: View {
    let state: SyncState
    let isConnected: Bool

    @State private var rotation: Double = 0
    @Environment(\.donkeyTheme) var theme

    public init(state: SyncState, isConnected: Bool = true) {
        self.state = state
        self.isConnected = isConnected
    }

    public var body: some View {
        Group {
            if !isConnected {
                Image(systemName: "icloud.slash")
                    .font(.system(size: 13))
                    .foregroundStyle(theme.colors.warning.opacity(0.8))
                    .transition(.opacity.combined(with: .scale))
            } else if isSyncing {
                Image(systemName: "arrow.trianglehead.2.clockwise")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.colors.accent)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        rotation = 0
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                    .onDisappear { rotation = 0 }
                    .transition(.opacity.combined(with: .scale))
            } else if isError {
                Image(systemName: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90")
                    .font(.system(size: 13))
                    .foregroundStyle(theme.colors.error.opacity(0.8))
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isConnected)
        .animation(.easeInOut(duration: 0.3), value: isSyncing)
        .animation(.easeInOut(duration: 0.3), value: isError)
    }

    private var isSyncing: Bool {
        if case .syncing = state { return true }
        return false
    }

    private var isError: Bool {
        if case .error = state { return true }
        return false
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 16) {
            SyncIndicatorView(state: .idle, isConnected: false)
            Text("Offline")
        }
        HStack(spacing: 16) {
            SyncIndicatorView(state: .syncing(progress: 0.5, completed: 5, total: 10))
            Text("Syncing")
        }
        HStack(spacing: 16) {
            SyncIndicatorView(state: .error(message: "Failed", lastSynced: nil))
            Text("Error")
        }
        HStack(spacing: 16) {
            SyncIndicatorView(state: .upToDate(lastSynced: .now))
            Text("Up to date (hidden)")
        }
    }
    .padding()
}
