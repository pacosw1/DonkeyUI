//
//  DonkeyPasteboardHelper.swift
//  DonkeyUI
//
//  Cross-platform pasteboard utilities for macOS, iOS, and visionOS.

import SwiftUI

// MARK: - Pasteboard Abstraction

/// Cross-platform pasteboard helper.
public enum DonkeyPasteboard {
    /// Copies text to the system pasteboard.
    public static func copy(_ text: String) {
        #if canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #elseif canImport(UIKit)
        UIPasteboard.general.string = text
        #endif
    }
}

// MARK: - Copyable Modifier

#if !os(watchOS)
public struct DonkeyCopyableModifier: ViewModifier {
    let text: String

    public func body(content: Content) -> some View {
        content.contextMenu {
            Button {
                DonkeyPasteboard.copy(text)
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
        }
    }
}

public extension View {
    /// Adds a "Copy" context menu item that copies the given text to the pasteboard.
    func donkeyCopyable(_ text: String) -> some View {
        modifier(DonkeyCopyableModifier(text: text))
    }
}
#endif
