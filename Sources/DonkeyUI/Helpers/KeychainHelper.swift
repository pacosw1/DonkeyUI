import Foundation
import Security

/// Simple keychain wrapper for storing tokens, API keys, and other secrets.
///
/// Uses the Security framework directly. The service name defaults to the app's bundle identifier.
///
/// Usage:
/// ```swift
/// // Save
/// KeychainHelper.save(key: "auth_token", value: "abc123")
///
/// // Load
/// if let token = KeychainHelper.load(key: "auth_token") {
///     print(token)
/// }
///
/// // Update
/// KeychainHelper.update(key: "auth_token", value: "xyz789")
///
/// // Delete
/// KeychainHelper.delete(key: "auth_token")
/// ```
public struct KeychainHelper {

    private init() {}

    private static var serviceName: String {
        Bundle.main.bundleIdentifier ?? "com.donkeyui.keychain"
    }

    /// Saves a string value to the keychain under the given key.
    ///
    /// If an entry already exists for this key, it will be updated instead.
    ///
    /// - Parameters:
    ///   - key: The identifier for the keychain item.
    ///   - value: The string value to store.
    /// - Returns: `true` if the save (or update) succeeded.
    @discardableResult
    public static func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Remove existing item first to avoid duplicates
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Loads a string value from the keychain for the given key.
    ///
    /// - Parameter key: The identifier for the keychain item.
    /// - Returns: The stored string, or `nil` if not found.
    public static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Deletes a keychain item for the given key.
    ///
    /// - Parameter key: The identifier for the keychain item.
    /// - Returns: `true` if the item was deleted or did not exist.
    @discardableResult
    public static func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// Updates an existing keychain item with a new value.
    ///
    /// If the item does not exist, this falls back to `save`.
    ///
    /// - Parameters:
    ///   - key: The identifier for the keychain item.
    ///   - value: The new string value.
    /// - Returns: `true` if the update succeeded.
    @discardableResult
    public static func update(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecItemNotFound {
            return save(key: key, value: value)
        }

        return status == errSecSuccess
    }
}
