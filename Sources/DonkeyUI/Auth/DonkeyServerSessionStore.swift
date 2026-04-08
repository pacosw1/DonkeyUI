import Foundation
import Security

public struct DonkeyServerSession: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String?
    public let updatedAt: Date

    public init(
        accessToken: String,
        refreshToken: String?,
        updatedAt: Date = Date()
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.updatedAt = updatedAt
    }
}

public final class DonkeyServerSessionStore: @unchecked Sendable {
    private let service: String
    private let account: String

    public init(
        service: String,
        account: String = "donkey-server-session"
    ) {
        self.service = service
        self.account = account
    }

    public func save(_ session: DonkeyServerSession) {
        guard let data = try? JSONEncoder().encode(session) else { return }
        delete()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    public func load() -> DonkeyServerSession? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return try? JSONDecoder().decode(DonkeyServerSession.self, from: data)
    }

    public func update(accessToken: String, refreshToken: String?) {
        save(DonkeyServerSession(accessToken: accessToken, refreshToken: refreshToken))
    }

    public func clear() {
        delete()
    }

    private func delete() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
