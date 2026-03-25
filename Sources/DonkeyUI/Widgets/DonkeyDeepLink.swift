import Foundation

/// Protocol for building type-safe deep links from widget taps.
public protocol DonkeyDeepLinkable {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

public extension DonkeyDeepLinkable {
    var scheme: String { "donkey" }
    var queryItems: [URLQueryItem] { [] }

    var url: URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path.hasPrefix("/") ? path : "/\(path)"
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        // Force-unwrap is safe because we control the components.
        return components.url!
    }
}

// MARK: - Deep Link Parser

public enum DonkeyDeepLink {
    /// Parses a URL into a `DonkeyDeepLinkable` enum case whose raw value matches the URL host.
    public static func parse<T: DonkeyDeepLinkable>(
        _ url: URL,
        as type: T.Type
    ) -> T? where T: RawRepresentable, T.RawValue == String {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else {
            return nil
        }
        return T(rawValue: host)
    }
}
