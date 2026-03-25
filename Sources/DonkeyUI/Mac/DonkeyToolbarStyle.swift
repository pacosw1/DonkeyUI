//
//  DonkeyToolbarStyle.swift
//  DonkeyUI
//
//  Toolbar modifier with leading/trailing content using platform-correct placements.

#if !os(watchOS)
import SwiftUI

public struct DonkeyToolbarModifier<Leading: View, Trailing: View>: ViewModifier {
    let leading: Leading
    let trailing: Trailing

    public func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItemGroup(placement: .navigation) {
                leading
            }
            #if os(macOS)
            ToolbarItemGroup(placement: .automatic) {
                trailing
            }
            #else
            ToolbarItemGroup(placement: .topBarTrailing) {
                trailing
            }
            #endif
        }
    }
}

public extension View {
    /// Adds themed toolbar items with leading and trailing content.
    func donkeyToolbar(
        @ViewBuilder leading: () -> some View,
        @ViewBuilder trailing: () -> some View
    ) -> some View {
        modifier(DonkeyToolbarModifier(leading: leading(), trailing: trailing()))
    }
}

#Preview {
    NavigationStack {
        Text("Content")
            .donkeyToolbar {
                Button("Back") {}
            } trailing: {
                Button("Save") {}
            }
    }
}
#endif
