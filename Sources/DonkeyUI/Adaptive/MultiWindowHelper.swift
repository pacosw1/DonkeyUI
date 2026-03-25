import SwiftUI

#if !os(watchOS)

// MARK: - DonkeyOpenWindowModifier

/// ViewModifier that provides access to `openWindow` for multi-window support.
private struct DonkeyOpenWindowModifier: ViewModifier {
    @Environment(\.openWindow) private var openWindow

    let windowId: String
    let action: (@Sendable (OpenWindowAction) -> Void)

    func body(content: Content) -> some View {
        content.onAppear {
            action(openWindow)
        }
    }
}

// MARK: - DonkeyMultiWindowSupport

/// A view that exposes the `openWindow` environment action via a callback.
/// Useful for triggering window opens from non-view code.
public struct DonkeyMultiWindowSupport: View {
    @Environment(\.openWindow) private var openWindow

    let onReady: (OpenWindowAction) -> Void

    public init(onReady: @escaping (OpenWindowAction) -> Void) {
        self.onReady = onReady
    }

    public var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear {
                onReady(openWindow)
            }
    }
}

// MARK: - View Extension

public extension View {
    /// Provides the `openWindow` action when the view appears.
    func donkeyOpenWindow(perform action: @escaping @Sendable (OpenWindowAction) -> Void) -> some View {
        modifier(DonkeyOpenWindowModifier(windowId: "", action: action))
    }
}

#endif
