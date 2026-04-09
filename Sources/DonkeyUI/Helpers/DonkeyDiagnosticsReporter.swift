import Foundation

public struct DonkeyDiagnosticsPayload: Codable, Sendable {
    public let category: String
    public let level: String
    public let message: String
    public let stack: String?
    public let appVersion: String?
    public let appBuild: String?
    public let language: String?
    public let deviceModel: String?
    public let osVersion: String?
    public let metadata: [String: String]

    enum CodingKeys: String, CodingKey {
        case category
        case level
        case message
        case stack
        case appVersion = "app_version"
        case appBuild = "app_build"
        case language
        case deviceModel = "device_model"
        case osVersion = "os_version"
        case metadata
    }
}

public actor DonkeyDiagnosticsReporter {
    private let endpoint: URL
    private let session: URLSession
    private let defaults: UserDefaults
    private let activeRunKey: String
    private let timestampKey: String

    public init(
        baseURL: URL,
        path: String = "/api/v1/errors",
        session: URLSession = .shared,
        defaults: UserDefaults = .standard,
        keyPrefix: String = "donkey.diagnostics"
    ) {
        self.endpoint = baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        self.session = session
        self.defaults = defaults
        self.activeRunKey = "\(keyPrefix).active-run"
        self.timestampKey = "\(keyPrefix).active-run-at"
    }

    public func markLaunch() async {
        if defaults.bool(forKey: activeRunKey) {
            let lastActiveAt = defaults.object(forKey: timestampKey) as? Date
            await report(
                category: "previous_run_unexpected_exit",
                message: "App appears to have ended unexpectedly during the previous active session",
                metadata: [
                    "last_active_at": lastActiveAt?.ISO8601Format() ?? "unknown",
                ]
            )
        }

        defaults.set(true, forKey: activeRunKey)
        defaults.set(Date(), forKey: timestampKey)
    }

    public func markAppDidBecomeActive() {
        defaults.set(true, forKey: activeRunKey)
        defaults.set(Date(), forKey: timestampKey)
    }

    public func markAppMovedToBackground() {
        defaults.set(false, forKey: activeRunKey)
        defaults.removeObject(forKey: timestampKey)
    }

    public func report(
        category: String,
        message: String,
        level: String = "error",
        error: Error? = nil,
        metadata: [String: String] = [:]
    ) async {
        guard !category.isEmpty, !message.isEmpty else { return }

        let payload = DonkeyDiagnosticsPayload(
            category: category,
            level: level,
            message: message,
            stack: error.map { String(describing: $0) },
            appVersion: bundleValue("CFBundleShortVersionString"),
            appBuild: bundleValue("CFBundleVersion"),
            language: Locale.preferredLanguages.first,
            deviceModel: DonkeyPushRegistration.deviceModel,
            osVersion: DonkeyPushRegistration.osVersion,
            metadata: metadata
        )

        guard let body = try? JSONEncoder().encode(payload) else { return }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(payload.language, forHTTPHeaderField: "X-Sacred-Language")
        request.setValue(payload.appVersion, forHTTPHeaderField: "X-App-Version")
        request.setValue(payload.appBuild, forHTTPHeaderField: "X-App-Build")
        request.setValue(payload.deviceModel, forHTTPHeaderField: "X-Device-Model")
        request.setValue(payload.osVersion, forHTTPHeaderField: "X-OS-Version")
        request.httpBody = body

        do {
            _ = try await session.data(for: request)
        } catch {
            // Diagnostics should never create a second failure path.
        }
    }

    public func measure<T>(
        category: String,
        thresholdMs: Double,
        metadata: [String: String] = [:],
        operation: () async throws -> T
    ) async rethrows -> T {
        let startedAt = Date()
        do {
            let value = try await operation()
            let durationMs = Date().timeIntervalSince(startedAt) * 1000
            if durationMs >= thresholdMs {
                await report(
                    category: category,
                    message: "Operation exceeded threshold",
                    level: "warn",
                    metadata: metadata.merging(["duration_ms": String(Int(durationMs))]) { _, new in new }
                )
            }
            return value
        } catch {
            await report(
                category: category,
                message: "Measured operation failed",
                level: "error",
                error: error,
                metadata: metadata
            )
            throw error
        }
    }

    private func bundleValue(_ key: String) -> String? {
        Bundle.main.infoDictionary?[key] as? String
    }
}
