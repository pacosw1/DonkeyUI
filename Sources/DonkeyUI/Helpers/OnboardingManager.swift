//
//  OnboardingManager.swift
//  Tracks onboarding completion and first-launch state.
//
//  Usage:
//  1. Create:
//     let onboarding = OnboardingManager()                    // uses UserDefaults.standard
//     let onboarding = OnboardingManager(suite: "group.app")  // for widget sharing
//
//  2. In your App struct:
//     if !onboarding.hasCompleted {
//         OnboardingFlow(pages: ...) { onboarding.complete() }
//     } else {
//         ContentView()
//     }
//
//  3. Or use the modifier:
//     ContentView()
//         .onboarding(manager: onboarding, pages: pages)
//

import SwiftUI

// MARK: - OnboardingManager

@Observable
@MainActor
public final class OnboardingManager {

    /// Whether onboarding has been completed
    public private(set) var hasCompleted: Bool

    /// Whether this is the very first app launch ever
    public let isFirstLaunch: Bool

    /// Current app version (for version-based re-onboarding)
    public let currentVersion: String

    private let defaults: UserDefaults
    private let completedKey: String
    private let versionKey: String
    private let sectionsKey: String

    /// Section IDs that have been completed (for immersive onboarding resume support).
    public private(set) var completedSections: Set<String>

    /// Create an onboarding manager.
    ///
    /// - Parameters:
    ///   - suite: UserDefaults suite name (for App Group sharing with widgets). nil = standard.
    ///   - completedKey: UserDefaults key for completion flag
    ///   - versionKey: UserDefaults key for last completed version
    public init(
        suite: String? = nil,
        completedKey: String = "donkey_onboarding_completed",
        versionKey: String = "donkey_onboarding_version",
        sectionsKey: String = "donkey_onboarding_sections"
    ) {
        let store = suite.flatMap { UserDefaults(suiteName: $0) } ?? .standard
        self.defaults = store
        self.completedKey = completedKey
        self.versionKey = versionKey
        self.sectionsKey = sectionsKey
        self.currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

        let wasCompleted = store.bool(forKey: completedKey)
        self.hasCompleted = wasCompleted
        self.isFirstLaunch = !wasCompleted && store.string(forKey: versionKey) == nil

        // Load completed sections
        if let data = store.data(forKey: sectionsKey),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.completedSections = ids
        } else {
            self.completedSections = []
        }
    }

    /// Mark onboarding as complete.
    public func complete() {
        hasCompleted = true
        defaults.set(true, forKey: completedKey)
        defaults.set(currentVersion, forKey: versionKey)
    }

    /// Reset onboarding (for testing or re-onboarding on major update).
    public func reset() {
        hasCompleted = false
        defaults.set(false, forKey: completedKey)
        defaults.removeObject(forKey: versionKey)
        completedSections = []
        defaults.removeObject(forKey: sectionsKey)
    }

    // MARK: - Section Tracking (Immersive Onboarding)

    /// Mark a specific section as completed. Used for resume-on-relaunch support.
    public func completeSection(_ id: String) {
        completedSections.insert(id)
        if let data = try? JSONEncoder().encode(completedSections) {
            defaults.set(data, forKey: sectionsKey)
        }
    }

    /// Check if a specific section has been completed.
    public func isSectionCompleted(_ id: String) -> Bool {
        completedSections.contains(id)
    }

    /// Check if onboarding should be shown again for a new app version.
    /// Pass the minimum version that requires re-onboarding.
    public func needsReOnboarding(since requiredVersion: String) -> Bool {
        guard hasCompleted else { return true }
        let lastVersion = defaults.string(forKey: versionKey) ?? "0.0.0"
        return lastVersion.compare(requiredVersion, options: .numeric) == .orderedAscending
    }
}

// MARK: - View Modifier

public struct OnboardingModifier: ViewModifier {
    let manager: OnboardingManager
    let pages: [OnboardingPageItem]

    public func body(content: Content) -> some View {
        if manager.hasCompleted {
            content
        } else {
            OnboardingFlow(
                pages: pages,
                onComplete: { manager.complete() }
            )
        }
    }
}

public extension View {
    /// Shows onboarding flow on first launch, then content after completion.
    func onboarding(
        manager: OnboardingManager,
        pages: [OnboardingPageItem]
    ) -> some View {
        modifier(OnboardingModifier(manager: manager, pages: pages))
    }
}
