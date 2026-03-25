#if !os(watchOS)
import Foundation
import os.log

private let logger = Logger(subsystem: "DonkeyUI", category: "AppUpdate")

public struct AppUpdateStatus: Sendable {
    public let currentVersion: String
    public let storeVersion: String
    public let storeURL: URL?
    public let isUpdateAvailable: Bool
    public let releaseNotes: String?
}

@Observable
@MainActor
public final class DonkeyAppUpdateChecker {
    public private(set) var status: AppUpdateStatus?
    public private(set) var isChecking = false

    public var countryCode: String?

    public init(countryCode: String? = nil) {
        self.countryCode = countryCode
    }

    /// Check the App Store for a newer version.
    public func check() async {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        guard !bundleId.isEmpty else {
            logger.error("No bundle identifier found")
            return
        }

        isChecking = true
        defer { isChecking = false }

        let cc = countryCode ?? Locale.current.region?.identifier ?? "US"
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)&country=\(cc)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(ITunesLookupResult.self, from: data)

            guard let app = result.results.first else {
                logger.debug("App not found on App Store")
                return
            }

            let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
            let isNewer = compareVersions(current: currentVersion, store: app.version)

            status = AppUpdateStatus(
                currentVersion: currentVersion,
                storeVersion: app.version,
                storeURL: URL(string: app.trackViewUrl),
                isUpdateAvailable: isNewer,
                releaseNotes: app.releaseNotes
            )

            logger.debug("Store version: \(app.version), current: \(currentVersion), update: \(isNewer)")
        } catch {
            logger.error("Update check failed: \(error.localizedDescription)")
        }
    }

    private func compareVersions(current: String, store: String) -> Bool {
        let c = current.split(separator: ".").compactMap { Int($0) }
        let s = store.split(separator: ".").compactMap { Int($0) }
        let maxLen = max(c.count, s.count)
        for i in 0..<maxLen {
            let cv = i < c.count ? c[i] : 0
            let sv = i < s.count ? s[i] : 0
            if sv > cv { return true }
            if sv < cv { return false }
        }
        return false
    }
}

// MARK: - iTunes API Response

private struct ITunesLookupResult: Decodable {
    let results: [ITunesApp]
}

private struct ITunesApp: Decodable {
    let version: String
    let trackViewUrl: String
    let releaseNotes: String?
}
#endif
