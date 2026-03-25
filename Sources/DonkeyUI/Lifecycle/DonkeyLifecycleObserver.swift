import SwiftUI
import os.log

private let logger = Logger(subsystem: "DonkeyUI", category: "Lifecycle")

@Observable
@MainActor
public final class DonkeyLifecycleObserver {
    public private(set) var currentPhase: ScenePhase = .active
    public private(set) var lastBackgroundedAt: Date?
    public private(set) var lastForegroundedAt: Date?

    private var handlers: [(ScenePhase, @MainActor () -> Void)] = []

    /// Time in background since last foreground
    public var backgroundDuration: TimeInterval? {
        guard let bg = lastBackgroundedAt else { return nil }
        if let fg = lastForegroundedAt, fg > bg { return fg.timeIntervalSince(bg) }
        return Date().timeIntervalSince(bg)
    }

    public init() {}

    /// Register a callback for a phase transition.
    public func onPhaseChange(to phase: ScenePhase, handler: @escaping @MainActor () -> Void) {
        handlers.append((phase, handler))
    }

    /// Feed ScenePhase changes. Called by the .observeLifecycle() modifier.
    public func phaseChanged(to newPhase: ScenePhase) {
        let oldPhase = currentPhase
        currentPhase = newPhase

        if newPhase == .background {
            lastBackgroundedAt = Date()
            logger.debug("App entered background")
        } else if newPhase == .active && oldPhase != .active {
            lastForegroundedAt = Date()
            logger.debug("App entered foreground")
        }

        for (phase, handler) in handlers where phase == newPhase {
            handler()
        }
    }
}

// MARK: - View Extension

public extension View {
    func observeLifecycle(_ observer: DonkeyLifecycleObserver) -> some View {
        modifier(LifecycleObserverModifier(observer: observer))
    }
}

private struct LifecycleObserverModifier: ViewModifier {
    let observer: DonkeyLifecycleObserver
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content.onChange(of: scenePhase) { _, newPhase in
            observer.phaseChanged(to: newPhase)
        }
    }
}
