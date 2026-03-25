//
//  DonkeyWindowHelper.swift
//  DonkeyUI
//
//  macOS window configuration helper using NSViewRepresentable.

#if os(macOS)
import SwiftUI
import AppKit

// MARK: - Window Accessor

struct DonkeyWindowAccessor: NSViewRepresentable {
    let titleBarHidden: Bool
    let minSize: CGSize?

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            if titleBarHidden {
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.insert(.fullSizeContentView)
            }
            if let minSize {
                window.minSize = minSize
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }
            if titleBarHidden {
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.insert(.fullSizeContentView)
            }
            if let minSize {
                window.minSize = minSize
            }
        }
    }
}

// MARK: - View Modifier

public struct DonkeyWindowStyleModifier: ViewModifier {
    let titleBarHidden: Bool
    let minSize: CGSize?

    public func body(content: Content) -> some View {
        content.background(
            DonkeyWindowAccessor(titleBarHidden: titleBarHidden, minSize: minSize)
        )
    }
}

public extension View {
    /// Configures the hosting macOS window's title bar and minimum size.
    func donkeyWindowStyle(titleBarHidden: Bool = false, minSize: CGSize? = nil) -> some View {
        modifier(DonkeyWindowStyleModifier(titleBarHidden: titleBarHidden, minSize: minSize))
    }
}

#Preview {
    Text("Custom Window")
        .frame(width: 400, height: 300)
        .donkeyWindowStyle(titleBarHidden: true, minSize: CGSize(width: 300, height: 200))
}
#endif
