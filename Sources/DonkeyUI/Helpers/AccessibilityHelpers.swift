import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// MARK: - AccessibilityHelper

public struct AccessibilityHelper {

    /// Whether the user has Reduce Motion enabled.
    public static var prefersReducedMotion: Bool {
        #if canImport(UIKit)
        return UIAccessibility.isReduceMotionEnabled
        #elseif canImport(AppKit)
        return NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        #else
        return false
        #endif
    }

    /// Whether VoiceOver is running.
    public static var isVoiceOverRunning: Bool {
        #if canImport(UIKit)
        return UIAccessibility.isVoiceOverRunning
        #elseif canImport(AppKit)
        return NSWorkspace.shared.isVoiceOverEnabled
        #else
        return false
        #endif
    }

    /// Current Dynamic Type size category.
    public static var contentSizeCategory: ContentSizeCategory {
        #if canImport(UIKit)
        let trait = UIApplication.shared.preferredContentSizeCategory
        return ContentSizeCategory(trait)
        #else
        return .medium
        #endif
    }

    /// Whether the user prefers large text (accessibility sizes).
    public static var prefersLargeText: Bool {
        #if canImport(UIKit)
        let category = UIApplication.shared.preferredContentSizeCategory
        return category >= .accessibilityMedium
        #else
        return false
        #endif
    }

    /// Whether Bold Text is enabled.
    public static var prefersBoldText: Bool {
        #if canImport(UIKit)
        return UIAccessibility.isBoldTextEnabled
        #else
        return false
        #endif
    }
}

// MARK: - ContentSizeCategory from UIKit

#if canImport(UIKit)
private extension ContentSizeCategory {
    init(_ uiCategory: UIContentSizeCategory) {
        switch uiCategory {
        case .extraSmall:                self = .extraSmall
        case .small:                     self = .small
        case .medium:                    self = .medium
        case .large:                     self = .large
        case .extraLarge:                self = .extraLarge
        case .extraExtraLarge:           self = .extraExtraLarge
        case .extraExtraExtraLarge:      self = .extraExtraExtraLarge
        case .accessibilityMedium:       self = .accessibilityMedium
        case .accessibilityLarge:        self = .accessibilityLarge
        case .accessibilityExtraLarge:   self = .accessibilityExtraLarge
        case .accessibilityExtraExtraLarge:  self = .accessibilityExtraExtraLarge
        case .accessibilityExtraExtraExtraLarge: self = .accessibilityExtraExtraExtraLarge
        default:                         self = .large
        }
    }
}
#endif

// MARK: - View Extension

public extension View {

    /// Apply animation only if Reduce Motion is NOT enabled.
    /// Falls back to no animation when the user prefers reduced motion.
    func animateUnlessReduced<V: Equatable>(_ animation: Animation, value: V) -> some View {
        self.animation(AccessibilityHelper.prefersReducedMotion ? nil : animation, value: value)
    }
}

// MARK: - Preview

#Preview("Accessibility Info") {
    struct DemoView: View {
        @State private var bouncing = false

        var body: some View {
            List {
                Section("Current Settings") {
                    row("Reduce Motion", AccessibilityHelper.prefersReducedMotion)
                    row("VoiceOver", AccessibilityHelper.isVoiceOverRunning)
                    row("Bold Text", AccessibilityHelper.prefersBoldText)
                    row("Large Text", AccessibilityHelper.prefersLargeText)
                    HStack {
                        Text("Size Category")
                        Spacer()
                        Text("\(AccessibilityHelper.contentSizeCategory)")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("animateUnlessReduced") {
                    Circle()
                        .fill(.blue)
                        .frame(width: 40, height: 40)
                        .offset(x: bouncing ? 100 : 0)
                        .animateUnlessReduced(.bouncy, value: bouncing)
                        .onTapGesture { bouncing.toggle() }

                    Text("Tap the circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }

        private func row(_ label: String, _ value: Bool) -> some View {
            HStack {
                Text(label)
                Spacer()
                Image(systemName: value ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(value ? .green : .secondary)
            }
        }
    }

    return DemoView()
}
