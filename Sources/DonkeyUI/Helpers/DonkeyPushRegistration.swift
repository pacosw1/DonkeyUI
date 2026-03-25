//
//  DonkeyPushRegistration.swift
//  DonkeyUI
//
//  Platform-aware push token registration helper.
//  Computes the correct APNs topic and platform string for each device type
//  (iOS, watchOS, macOS) so the server can route pushes with the right topic.
//
//  Also provides a stable `installationId` (UUID persisted per app install)
//  so the server can identify which device originated a sync and exclude it
//  from push notifications for that change.
//
//  Usage:
//  // In AppDelegate or WKApplicationDelegate:
//  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//      let tokenString = DonkeyPushRegistration.tokenString(from: deviceToken)
//      let payload = DonkeyPushRegistration.deviceRegistrationPayload(
//          token: tokenString,
//          deviceName: UIDevice.current.name
//      )
//
//      Task {
//          try await api.registerDevice(payload)
//      }
//  }
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(WatchKit)
import WatchKit
#endif

/// Helpers for registering push tokens with the correct platform, APNs topic,
/// and a stable installation ID for server-side device identification.
public enum DonkeyPushRegistration {

    // MARK: - Installation ID

    private static let installationIdKey = "donkey.installationId"

    /// Stable UUID that identifies this app installation.
    /// Generated once on first access and persisted in UserDefaults.
    /// Use this to let the server exclude the originating device from sync pushes.
    public static var installationId: String {
        if let existing = UserDefaults.standard.string(forKey: installationIdKey) {
            return existing
        }
        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: installationIdKey)
        return id
    }

    // MARK: - Platform Detection

    /// Platform string matching donkey-swift's expected values.
    public static var platform: String {
        #if os(watchOS)
        "watchos"
        #elseif os(macOS)
        "macos"
        #else
        "ios"
        #endif
    }

    /// Compute the APNs topic for the current platform.
    ///
    /// - iOS/macOS: returns the bundle ID as-is (e.g. `com.myapp`)
    /// - watchOS: appends `.watchkitapp` (e.g. `com.myapp.watchkitapp`)
    ///
    /// The server uses this to set the `apns-topic` header when pushing to this device.
    public static func apnsTopic(bundleId: String) -> String {
        #if os(watchOS)
        return "\(bundleId).watchkitapp"
        #else
        return bundleId
        #endif
    }

    /// APNs topic for complication pushes (watchOS only).
    /// Returns nil on non-watchOS platforms.
    public static func complicationTopic(bundleId: String) -> String? {
        #if os(watchOS)
        return "\(bundleId).watchkitapp.complication"
        #else
        return nil
        #endif
    }

    // MARK: - Token Conversion

    /// Convert raw device token data to a hex string for server registration.
    public static func tokenString(from deviceToken: Data) -> String {
        deviceToken.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Device Info

    /// Current device model string (e.g. "iPhone15,2", "Watch6,1").
    public static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "unknown"
            }
        }
    }

    /// Current OS version string (e.g. "17.4", "10.3").
    public static var osVersion: String {
        #if os(watchOS)
        WKInterfaceDevice.current().systemVersion
        #elseif canImport(UIKit)
        UIDevice.current.systemVersion
        #else
        ProcessInfo.processInfo.operatingSystemVersionString
        #endif
    }

    // MARK: - Registration Payload

    /// Builds a dictionary with all fields needed for device registration.
    ///
    /// - Parameters:
    ///   - token: Hex-encoded APNs device token (from `tokenString(from:)`).
    ///   - deviceName: User-facing device name (e.g. `UIDevice.current.name`).
    /// - Returns: Dictionary suitable for JSON serialization and sending to the server.
    public static func deviceRegistrationPayload(
        token: String,
        deviceName: String
    ) -> [String: String?] {
        [
            "token": token,
            "platform": platform,
            "installation_id": installationId,
            "device_name": deviceName,
            "device_model": deviceModel,
            "os_version": osVersion,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        ]
    }
}
