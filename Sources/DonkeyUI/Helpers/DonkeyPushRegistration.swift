//
//  DonkeyPushRegistration.swift
//  DonkeyUI
//
//  Platform-aware push token registration helper.
//  Computes the correct APNs topic and platform string for each device type
//  (iOS, watchOS, macOS) so the server can route pushes with the right topic.
//
//  Usage:
//  // In AppDelegate or WKApplicationDelegate:
//  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//      let tokenString = DonkeyPushRegistration.tokenString(from: deviceToken)
//      let topic = DonkeyPushRegistration.apnsTopic(bundleId: Bundle.main.bundleIdentifier!)
//      let platform = DonkeyPushRegistration.platform
//
//      Task {
//          try await api.registerDevice(
//              token: tokenString,
//              platform: platform,
//              apnsTopic: topic,
//              deviceModel: DonkeyPushRegistration.deviceModel,
//              osVersion: DonkeyPushRegistration.osVersion
//          )
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

/// Helpers for registering push tokens with the correct platform and APNs topic.
public enum DonkeyPushRegistration {

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
}
