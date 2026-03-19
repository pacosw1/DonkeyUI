//
//  ProFeatureGate.swift
//  Locks content behind pro. Shows paywall when tapped.
//
//  Usage:
//  Button("Export PDF") { exportPDF() }
//      .proGated(store: store, showPaywall: $showPaywall)
//
//  // Or as a standalone view:
//  ProFeatureGate(store: store, showPaywall: $showPaywall) {
//      Text("Pro Feature")
//  }
//

import SwiftUI

// MARK: - ProFeatureGate View

public struct ProFeatureGate<Content: View>: View {
    let store: DonkeyStoreManager
    @Binding var showPaywall: Bool
    let lockedIcon: String
    let lockedMessage: String
    @ViewBuilder let content: () -> Content

    @Environment(\.donkeyTheme) var theme

    public init(
        store: DonkeyStoreManager,
        showPaywall: Binding<Bool>,
        lockedIcon: String = "lock.fill",
        lockedMessage: String = "Upgrade to Pro",
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.store = store
        self._showPaywall = showPaywall
        self.lockedIcon = lockedIcon
        self.lockedMessage = lockedMessage
        self.content = content
    }

    public var body: some View {
        if store.isPro {
            content()
        } else {
            Button {
                showPaywall = true
            } label: {
                HStack(spacing: theme.spacing.sm) {
                    Image(systemName: lockedIcon)
                        .foregroundColor(theme.colors.accent)
                    Text(lockedMessage)
                        .font(theme.typography.subheadline)
                        .foregroundColor(theme.colors.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(theme.spacing.lg)
                .bgOverlay(
                    bgColor: theme.colors.surface,
                    radius: theme.shape.radiusMedium,
                    borderColor: theme.colors.borderSubtle,
                    borderWidth: 1
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - View Modifier

public struct ProGatedModifier: ViewModifier {
    let store: DonkeyStoreManager
    @Binding var showPaywall: Bool

    public func body(content: Content) -> some View {
        content
            .disabled(!store.isPro)
            .overlay {
                if !store.isPro {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showPaywall = true
                        }
                }
            }
            .opacity(store.isPro ? 1 : 0.5)
    }
}

public extension View {
    /// Dims and intercepts taps when not pro, opening the paywall instead.
    func proGated(store: DonkeyStoreManager, showPaywall: Binding<Bool>) -> some View {
        modifier(ProGatedModifier(store: store, showPaywall: showPaywall))
    }
}
