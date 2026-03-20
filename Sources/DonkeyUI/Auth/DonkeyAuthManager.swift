//
//  DonkeyAuthManager.swift
//  Apple Sign In session management. Handles auth, Keychain persistence, server sync.
//
//  Usage:
//  1. Create with your server sync callback:
//     let auth = DonkeyAuthManager(
//         keychainService: "com.myapp",
//         onSignIn: { user, idToken in await api.signIn(token: idToken, name: user.name ?? "") }
//     )
//
//  2. Inject into environment:
//     ContentView().environment(auth)
//
//  3. Use in views:
//     @Environment(DonkeyAuthManager.self) var auth
//     if auth.isAuthenticated { ... }
//

import Foundation
import AuthenticationServices
import SwiftUI
import os.log

private let logger = Logger(subsystem: "DonkeyUI", category: "Auth")

// MARK: - Auth User

/// Codable user model stored in Keychain.
public struct DonkeyAuthUser: Codable, Sendable {
    public let id: String
    public let email: String
    public let name: String?
    public let createdAt: Date?

    public init(id: String, email: String, name: String?, createdAt: Date? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.createdAt = createdAt
    }
}

// MARK: - Auth Callbacks

/// Server sync callback. Called after successful Apple Sign In.
/// Parameters: (user, identityToken) → return updated name from server if available.
public struct AuthCallbacks: Sendable {
    public let onSignIn: @Sendable (DonkeyAuthUser, String) async -> String?
    public let onSignOut: @Sendable () async -> Void

    public init(
        onSignIn: @escaping @Sendable (DonkeyAuthUser, String) async -> String? = { _, _ in nil },
        onSignOut: @escaping @Sendable () async -> Void = {}
    ) {
        self.onSignIn = onSignIn
        self.onSignOut = onSignOut
    }
}

// MARK: - DonkeyAuthManager

@Observable
@MainActor
public final class DonkeyAuthManager {

    // MARK: - Public State

    /// The current authenticated user (nil if signed out)
    public private(set) var user: DonkeyAuthUser?

    /// Whether a sign-in is in progress
    public private(set) var isLoading = false

    /// Whether initial session has been resolved from Keychain
    public private(set) var hasResolvedInitialSession = false

    /// Error message from the last failed operation
    public private(set) var errorMessage: String?

    /// Whether user is currently authenticated
    public var isAuthenticated: Bool { user != nil }

    // MARK: - Private

    private let keychainService: String
    private let keychainKey: String
    private let callbacks: AuthCallbacks

    // MARK: - Init

    /// Create an auth manager.
    ///
    /// - Parameters:
    ///   - keychainService: Your app's bundle ID or unique service name for Keychain storage
    ///   - keychainKey: Key name for the stored user (default: "donkey-auth-user")
    ///   - callbacks: Server sync callbacks
    public init(
        keychainService: String,
        keychainKey: String = "donkey-auth-user",
        callbacks: AuthCallbacks = AuthCallbacks()
    ) {
        self.keychainService = keychainService
        self.keychainKey = keychainKey
        self.callbacks = callbacks

        // Load cached user from Keychain
        self.user = loadFromKeychain()
        self.hasResolvedInitialSession = true
    }

    // MARK: - Apple Sign In

    /// Handle the result from `SignInWithAppleButton`. Call this in the `onCompletion` handler.
    public func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let err):
            // Don't show error for user cancellation
            if (err as NSError).code == ASAuthorizationError.canceled.rawValue {
                errorMessage = nil
                return
            }
            errorMessage = err.localizedDescription
            logger.error("Apple Sign In failed: \(err)")

        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Unexpected credential format"
                return
            }

            isLoading = true
            errorMessage = nil

            let appleUserID = credential.user
            let newEmail = credential.email ?? ""
            let newName = Self.fullNameString(from: credential.fullName)

            // Apple only sends name/email on FIRST sign-in — merge with cached
            let existingUser = loadFromKeychain()
            let email = newEmail.isEmpty ? (existingUser?.email ?? "") : newEmail
            let name = newName ?? existingUser?.name

            guard let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8) else {
                errorMessage = "Failed to get identity token from Apple"
                isLoading = false
                return
            }

            let localUser = DonkeyAuthUser(id: appleUserID, email: email, name: name)
            user = localUser
            saveToKeychain(localUser)

            logger.info("Apple Sign In successful: \(appleUserID)")

            // Server sync (non-blocking — user is already signed in locally)
            Task {
                defer { isLoading = false }
                let serverName = await callbacks.onSignIn(localUser, idToken)
                // If server returns a name and we don't have one, update
                if let serverName, !serverName.isEmpty, name == nil {
                    let updated = DonkeyAuthUser(id: appleUserID, email: email, name: serverName)
                    self.user = updated
                    saveToKeychain(updated)
                }
            }
        }
    }

    // MARK: - Sign Out

    /// Sign out the current user. Clears Keychain and notifies server.
    public func signOut() {
        user = nil
        clearKeychain()
        errorMessage = nil
        logger.info("User signed out")

        Task {
            await callbacks.onSignOut()
        }
    }

    // MARK: - Keychain

    private func saveToKeychain(_ user: DonkeyAuthUser) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        deleteFromKeychain()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadFromKeychain() -> DonkeyAuthUser? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return try? JSONDecoder().decode(DonkeyAuthUser.self, from: data)
    }

    private func clearKeychain() {
        deleteFromKeychain()
    }

    private func deleteFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainKey,
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Helpers

    private static func fullNameString(from components: PersonNameComponents?) -> String? {
        guard let components else { return nil }
        let formatter = PersonNameComponentsFormatter()
        let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? nil : name
    }
}
