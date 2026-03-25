//
//  DonkeyMenuBarHelper.swift
//  DonkeyUI
//
//  Reusable menu bar section and row components for macOS menu extras.

#if os(macOS)
import SwiftUI

/// A titled section for organizing menu bar content.
public struct DonkeyMenuBarSection<Content: View>: View {
    @Environment(\.donkeyTheme) var theme

    let title: String
    let content: Content

    public init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.secondary)
                .padding(.horizontal, theme.spacing.sm)

            content
        }
    }
}

/// A single row in a menu bar dropdown with icon, title, optional shortcut, and action.
public struct DonkeyMenuBarRow: View {
    @Environment(\.donkeyTheme) var theme

    let icon: String
    let title: String
    let shortcut: String?
    let action: () -> Void

    public init(icon: String, title: String, shortcut: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.shortcut = shortcut
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: icon)
                    .frame(width: 16)
                    .foregroundStyle(theme.colors.primary)

                Text(title)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.onSurface)

                Spacer()

                if let shortcut {
                    Text(shortcut)
                        .font(theme.typography.caption.monospaced())
                        .foregroundStyle(theme.colors.secondary)
                }
            }
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        DonkeyMenuBarSection(title: "Actions") {
            DonkeyMenuBarRow(icon: "plus", title: "New Window", shortcut: "\u{2318}N") {}
            DonkeyMenuBarRow(icon: "gear", title: "Preferences", shortcut: "\u{2318},") {}
            DonkeyMenuBarRow(icon: "power", title: "Quit") {}
        }
    }
    .padding()
    .frame(width: 250)
}
#endif
