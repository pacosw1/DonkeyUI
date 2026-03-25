//
//  DonkeySettingsTab.swift
//  DonkeyUI
//
//  macOS Settings tab wrapper with themed styling.

#if os(macOS)
import SwiftUI

/// A themed settings tab for macOS Settings/Preferences windows.
public struct DonkeySettingsTab<Content: View>: View {
    @Environment(\.donkeyTheme) var theme

    let label: String
    let systemImage: String
    let content: Content

    public init(
        _ label: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.systemImage = systemImage
        self.content = content()
    }

    public var body: some View {
        Form {
            content
        }
        .formStyle(.grouped)
        .frame(minWidth: 450, maxWidth: 600)
        .padding(theme.spacing.md)
        .tabItem {
            Label(label, systemImage: systemImage)
        }
    }
}

#Preview {
    TabView {
        DonkeySettingsTab("General", systemImage: "gear") {
            Toggle("Enable notifications", isOn: .constant(true))
            Toggle("Dark mode", isOn: .constant(false))
        }

        DonkeySettingsTab("Advanced", systemImage: "wrench") {
            Text("Advanced settings go here")
        }
    }
    .frame(width: 500, height: 300)
}
#endif
