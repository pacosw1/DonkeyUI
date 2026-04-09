import Foundation

public enum DonkeyDiagnosticsLevel: String, Codable, Sendable {
    case debug
    case info
    case warn
    case error
}

public enum DonkeyDiagnosticEventType: String, Codable, Sendable {
    case error
    case crash
    case performance
    case lifecycle
}

public struct DonkeyDiagnosticBreadcrumb: Codable, Sendable {
    public let ts: String
    public let level: DonkeyDiagnosticsLevel
    public let category: String
    public let message: String
    public let metadata: [String: String]

    public init(
        ts: String = ISO8601DateFormatter().string(from: .now),
        level: DonkeyDiagnosticsLevel = .info,
        category: String,
        message: String,
        metadata: [String: String] = [:]
    ) {
        self.ts = ts
        self.level = level
        self.category = category
        self.message = message
        self.metadata = metadata
    }
}

public struct DonkeyDiagnosticsPayload: Codable, Sendable {
    public let type: DonkeyDiagnosticEventType
    public let category: String
    public let level: DonkeyDiagnosticsLevel
    public let message: String
    public let stack: String?
    public let sessionID: String?
    public let installationID: String?
    public let appVersion: String?
    public let appBuild: String?
    public let language: String?
    public let deviceModel: String?
    public let osVersion: String?
    public let platform: String?
    public let breadcrumbs: [DonkeyDiagnosticBreadcrumb]
    public let metadata: [String: String]

    enum CodingKeys: String, CodingKey {
        case type
        case category
        case level
        case message
        case stack
        case sessionID = "session_id"
        case installationID = "installation_id"
        case appVersion = "app_version"
        case appBuild = "app_build"
        case language
        case deviceModel = "device_model"
        case osVersion = "os_version"
        case platform
        case breadcrumbs
        case metadata
    }
}

public actor DonkeyDiagnosticsReporter {
    private let endpoint: URL
    private let session: URLSession
    private let defaults: UserDefaults
    private let activeRunKey: String
    private let timestampKey: String
    private let sessionKey: String
    private let breadcrumbsKey: String
    private let maxBreadcrumbs: Int
    private let headersProvider: (@Sendable () async -> [String: String])?
    private let installationIDProvider: (@Sendable () -> String?)?

    public init(
        baseURL: URL,
        path: String = "/api/v1/diagnostics/events",
        session: URLSession = .shared,
        defaults: UserDefaults = .standard,
        keyPrefix: String = "donkey.diagnostics",
        maxBreadcrumbs: Int = 40,
        headersProvider: (@Sendable () async -> [String: String])? = nil,
        installationIDProvider: (@Sendable () -> String?)? = nil
    ) {
        self.endpoint = baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        self.session = session
        self.defaults = defaults
        self.activeRunKey = "\(keyPrefix).active-run"
        self.timestampKey = "\(keyPrefix).active-run-at"
        self.sessionKey = "\(keyPrefix).session-id"
        self.breadcrumbsKey = "\(keyPrefix).breadcrumbs"
        self.maxBreadcrumbs = max(1, maxBreadcrumbs)
        self.headersProvider = headersProvider
        self.installationIDProvider = installationIDProvider
    }

    public func markLaunch() async {
        let lastActiveAt = defaults.object(forKey: timestampKey) as? Date
        let existingBreadcrumbs = loadBreadcrumbs()
        let sessionID = currentSessionID()

        if defaults.bool(forKey: activeRunKey) {
            await submit(
                type: .crash,
                category: "previous_run_unexpected_exit",
                message: "App appears to have ended unexpectedly during the previous active session",
                level: .error,
                metadata: [
                    "last_active_at": lastActiveAt?.ISO8601Format() ?? "unknown",
                ],
                breadcrumbs: existingBreadcrumbs,
                sessionID: sessionID
            )
        }

        defaults.set(true, forKey: activeRunKey)
        defaults.set(Date(), forKey: timestampKey)
        defaults.set(UUID().uuidString, forKey: sessionKey)
    }

    public func markAppDidBecomeActive() {
        defaults.set(true, forKey: activeRunKey)
        defaults.set(Date(), forKey: timestampKey)
    }

    public func markAppMovedToBackground() {
        defaults.set(false, forKey: activeRunKey)
        defaults.removeObject(forKey: timestampKey)
    }

    public func addBreadcrumb(
        category: String,
        message: String,
        level: DonkeyDiagnosticsLevel = .info,
        metadata: [String: String] = [:]
    ) {
        guard !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        var breadcrumbs = loadBreadcrumbs()
        breadcrumbs.append(
            DonkeyDiagnosticBreadcrumb(
                level: level,
                category: category,
                message: message,
                metadata: metadata
            )
        )

        if breadcrumbs.count > maxBreadcrumbs {
            breadcrumbs = Array(breadcrumbs.suffix(maxBreadcrumbs))
        }

        saveBreadcrumbs(breadcrumbs)
    }

    public func trackScreen(_ screen: String, metadata: [String: String] = [:]) {
        addBreadcrumb(
            category: "screen_view",
            message: screen,
            level: .info,
            metadata: metadata
        )
    }

    public func report(
        category: String,
        message: String,
        level: DonkeyDiagnosticsLevel = .error,
        error: Error? = nil,
        metadata: [String: String] = [:]
    ) async {
        await submit(
            type: .error,
            category: category,
            message: message,
            level: level,
            error: error,
            metadata: metadata
        )
    }

    public func reportCrashSignal(
        category: String = "probable_crash",
        message: String,
        metadata: [String: String] = [:]
    ) async {
        await submit(
            type: .crash,
            category: category,
            message: message,
            level: .error,
            metadata: metadata
        )
    }

    public func reportPerformance(
        category: String,
        message: String = "Operation exceeded threshold",
        durationMs: Double,
        level: DonkeyDiagnosticsLevel = .warn,
        metadata: [String: String] = [:]
    ) async {
        await submit(
            type: .performance,
            category: category,
            message: message,
            level: level,
            metadata: metadata.merging(["duration_ms": String(Int(durationMs.rounded()))]) { _, newValue in newValue }
        )
    }

    public func reportNetworkFailure(
        method: String,
        url: String,
        statusCode: Int? = nil,
        error: Error? = nil,
        metadata: [String: String] = [:]
    ) async {
        var eventMetadata = metadata
        eventMetadata["http_method"] = method
        eventMetadata["url"] = url
        if let statusCode {
            eventMetadata["status_code"] = String(statusCode)
        }

        await submit(
            type: .error,
            category: "network_request_failed",
            message: "Network request failed",
            level: .error,
            error: error,
            metadata: eventMetadata
        )
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
                await reportPerformance(
                    category: category,
                    durationMs: durationMs,
                    metadata: metadata
                )
            }

            return value
        } catch {
            await submit(
                type: .error,
                category: category,
                message: "Measured operation failed",
                level: .error,
                error: error,
                metadata: metadata
            )
            throw error
        }
    }

    private func submit(
        type: DonkeyDiagnosticEventType,
        category: String,
        message: String,
        level: DonkeyDiagnosticsLevel,
        error: Error? = nil,
        metadata: [String: String] = [:],
        breadcrumbs: [DonkeyDiagnosticBreadcrumb]? = nil,
        sessionID: String? = nil
    ) async {
        guard !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        let payload = DonkeyDiagnosticsPayload(
            type: type,
            category: category,
            level: level,
            message: message,
            stack: error.map { String(describing: $0) },
            sessionID: sessionID ?? currentSessionID(),
            installationID: installationIDProvider?(),
            appVersion: bundleValue("CFBundleShortVersionString"),
            appBuild: bundleValue("CFBundleVersion"),
            language: Locale.preferredLanguages.first,
            deviceModel: DonkeyPushRegistration.deviceModel,
            osVersion: DonkeyPushRegistration.osVersion,
            platform: "ios",
            breadcrumbs: breadcrumbs ?? loadBreadcrumbs(),
            metadata: metadata
        )

        guard let body = try? JSONEncoder().encode(payload) else {
            return
        }

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

        if let headersProvider {
            let extraHeaders = await headersProvider()
            for (header, value) in extraHeaders where !value.isEmpty {
                request.setValue(value, forHTTPHeaderField: header)
            }
        }

        do {
            _ = try await session.data(for: request)
        } catch {
            // Diagnostics should never create a second failure path.
        }
    }

    private func currentSessionID() -> String? {
        defaults.string(forKey: sessionKey)
    }

    private func loadBreadcrumbs() -> [DonkeyDiagnosticBreadcrumb] {
        guard let data = defaults.data(forKey: breadcrumbsKey),
              let breadcrumbs = try? JSONDecoder().decode([DonkeyDiagnosticBreadcrumb].self, from: data) else {
            return []
        }

        return breadcrumbs
    }

    private func saveBreadcrumbs(_ breadcrumbs: [DonkeyDiagnosticBreadcrumb]) {
        guard let data = try? JSONEncoder().encode(breadcrumbs) else {
            return
        }

        defaults.set(data, forKey: breadcrumbsKey)
    }

    private func bundleValue(_ key: String) -> String? {
        Bundle.main.infoDictionary?[key] as? String
    }
}
