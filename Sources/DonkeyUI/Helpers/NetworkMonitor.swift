import Foundation
import Network
import Combine

/// Observable network connectivity monitor powered by `NWPathMonitor`.
///
/// Publishes real-time connection status and type. Starts monitoring automatically on init.
///
/// Usage in SwiftUI:
/// ```swift
/// struct ContentView: View {
///     @ObservedObject private var network = NetworkMonitor.shared
///
///     var body: some View {
///         if !network.isConnected {
///             Text("No internet connection")
///         }
///     }
/// }
/// ```
///
/// Usage in non-UI code:
/// ```swift
/// if NetworkMonitor.shared.isConnected {
///     fetchData()
/// }
/// ```
public final class NetworkMonitor: ObservableObject {

    /// Shared singleton instance. Monitoring starts on first access.
    public static let shared = NetworkMonitor()

    /// Whether the device currently has network connectivity.
    @Published public private(set) var isConnected: Bool = true

    /// The current connection type (wifi, cellular, ethernet, or unknown).
    @Published public private(set) var connectionType: ConnectionType = .unknown

    /// Describes the type of network connection.
    public enum ConnectionType: String, Sendable {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.donkeyui.networkmonitor", qos: .utility)

    public init() {
        monitor = NWPathMonitor()
        start()
    }

    deinit {
        stop()
    }

    /// Starts network path monitoring.
    ///
    /// Called automatically on init. Safe to call again after `stop()`.
    public func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let connected = path.status == .satisfied
            let type = Self.resolveConnectionType(path)

            DispatchQueue.main.async {
                self.isConnected = connected
                self.connectionType = type
            }
        }
        monitor.start(queue: queue)
    }

    /// Stops network path monitoring.
    ///
    /// Call this when monitoring is no longer needed (e.g., app entering background for extended periods).
    public func stop() {
        monitor.cancel()
    }

    // MARK: - Private

    private static func resolveConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
}
