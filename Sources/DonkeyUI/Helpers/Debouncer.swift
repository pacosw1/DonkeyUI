import SwiftUI

// MARK: - Debouncer

/// Actor-based debouncer for search, auto-save, and other high-frequency operations.
///
/// Usage:
/// ```swift
/// let debouncer = Debouncer(duration: .milliseconds(300))
/// await debouncer.debounce {
///     await performSearch(query)
/// }
/// ```
public actor Debouncer {
    private let duration: Duration
    private var task: Task<Void, Never>?

    /// Creates a debouncer with the specified delay.
    /// - Parameter duration: The debounce interval. Defaults to 300ms.
    public init(duration: Duration = .milliseconds(300)) {
        self.duration = duration
    }

    /// Schedules an action to execute after the debounce interval.
    /// Any previously scheduled action is cancelled.
    /// - Parameter action: The async closure to execute after the delay.
    public func debounce(action: @escaping @Sendable () async -> Void) {
        task?.cancel()
        task = Task {
            do {
                try await Task.sleep(for: duration)
                guard !Task.isCancelled else { return }
                await action()
            } catch {
                // Task was cancelled — expected behavior
            }
        }
    }

    /// Cancels any pending debounced action.
    public func cancel() {
        task?.cancel()
        task = nil
    }
}

// MARK: - View Extension

public extension View {
    /// Performs an action after a debounce delay whenever the observed value changes.
    ///
    /// Usage:
    /// ```swift
    /// TextField("Search", text: $query)
    ///     .onDebounce(of: query, duration: .milliseconds(500)) {
    ///         performSearch()
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - value: The value to observe for changes.
    ///   - duration: The debounce interval. Defaults to 300ms.
    ///   - perform: The closure to execute after the delay.
    /// - Returns: A view that debounces the action on value changes.
    func onDebounce<V: Equatable>(
        of value: V,
        duration: Duration = .milliseconds(300),
        perform action: @escaping () -> Void
    ) -> some View {
        modifier(DebounceModifier(value: value, duration: duration, action: action))
    }
}

// MARK: - DebounceModifier

private struct DebounceModifier<V: Equatable>: ViewModifier {
    let value: V
    let duration: Duration
    let action: () -> Void

    @State private var debounceTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .onChange(of: value) {
                debounceTask?.cancel()
                debounceTask = Task {
                    do {
                        try await Task.sleep(for: duration)
                        guard !Task.isCancelled else { return }
                        action()
                    } catch {
                        // Cancelled
                    }
                }
            }
    }
}
