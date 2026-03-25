//
//  DonkeySidebarNavigation.swift
//  DonkeyUI
//
//  Themed NavigationSplitView wrapper for sidebar-detail layouts.

#if !os(watchOS)
import SwiftUI

/// A themed `NavigationSplitView` wrapper with sidebar and detail panes.
public struct DonkeySidebarNavigation<Sidebar: View, Detail: View>: View {
    @Environment(\.donkeyTheme) var theme

    @Binding var columnVisibility: NavigationSplitViewVisibility
    let sidebar: Sidebar
    let detail: Detail

    /// Creates a sidebar navigation layout.
    /// - Parameters:
    ///   - columnVisibility: Binding controlling sidebar visibility.
    ///   - sidebar: The sidebar content.
    ///   - detail: The detail content.
    public init(
        columnVisibility: Binding<NavigationSplitViewVisibility> = .constant(.automatic),
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder detail: () -> Detail
    ) {
        self._columnVisibility = columnVisibility
        self.sidebar = sidebar()
        self.detail = detail()
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
                .background(theme.colors.surface)
        } detail: {
            detail
                .background(theme.colors.background)
        }
    }
}

#Preview {
    DonkeySidebarNavigation {
        List {
            Text("Item 1")
            Text("Item 2")
            Text("Item 3")
        }
        .navigationTitle("Sidebar")
    } detail: {
        Text("Select an item")
    }
}
#endif
