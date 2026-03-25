//
//  DonkeyKeyboardShortcut.swift
//  DonkeyUI
//
//  Keyboard shortcut modifier and help overlay.

#if !os(watchOS)
import SwiftUI

// MARK: - Shortcut Modifier

public struct DonkeyShortcutModifier: ViewModifier {
    let key: KeyEquivalent
    let modifiers: EventModifiers

    public func body(content: Content) -> some View {
        content.keyboardShortcut(key, modifiers: modifiers)
    }
}

public extension View {
    /// Applies a keyboard shortcut to the view.
    func donkeyShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = .command) -> some View {
        modifier(DonkeyShortcutModifier(key: key, modifiers: modifiers))
    }
}

// MARK: - Shortcut Descriptor

/// Describes a keyboard shortcut for display in a help overlay.
public struct DonkeyShortcutDescriptor: Identifiable {
    public let id = UUID()
    public let title: String
    public let key: String
    public let modifiers: String

    public init(title: String, key: String, modifiers: String = "\u{2318}") {
        self.title = title
        self.key = key
        self.modifiers = modifiers
    }
}

// MARK: - Shortcut Group (Help Overlay)

/// Renders a styled list of keyboard shortcuts for a help overlay.
public struct DonkeyShortcutGroup: View {
    @Environment(\.donkeyTheme) var theme

    let title: String
    let shortcuts: [DonkeyShortcutDescriptor]

    public init(title: String = "Keyboard Shortcuts", shortcuts: [DonkeyShortcutDescriptor]) {
        self.title = title
        self.shortcuts = shortcuts
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.headline)
                .foregroundStyle(theme.colors.onSurface)

            ForEach(shortcuts) { shortcut in
                HStack {
                    Text(shortcut.title)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.onSurface)

                    Spacer()

                    Text("\(shortcut.modifiers)\(shortcut.key)")
                        .font(theme.typography.callout.monospaced())
                        .foregroundStyle(theme.colors.secondary)
                        .padding(.horizontal, theme.spacing.xs)
                        .padding(.vertical, theme.spacing.xxs)
                        .background(theme.colors.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: theme.shape.radiusSmall))
                }
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.shape.radiusMedium))
    }
}

// MARK: - Preview

#Preview {
    DonkeyShortcutGroup(shortcuts: [
        DonkeyShortcutDescriptor(title: "New Item", key: "N"),
        DonkeyShortcutDescriptor(title: "Save", key: "S"),
        DonkeyShortcutDescriptor(title: "Find", key: "F"),
    ])
    .padding()
}
#endif
