import SwiftUI

#if !os(watchOS)

// MARK: - SplitDetailView

/// A `NavigationSplitView` wrapper with sidebar and detail panes.
/// Shows a themed empty state when no item is selected.
public struct SplitDetailView<Item: Hashable & Identifiable, Sidebar: View, Detail: View>: View {
    @Environment(\.donkeyTheme) var theme
    @Binding var selection: Item?

    let sidebar: () -> Sidebar
    let detail: (Item) -> Detail

    public init(
        selection: Binding<Item?>,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder detail: @escaping (Item) -> Detail
    ) {
        self._selection = selection
        self.sidebar = sidebar
        self.detail = detail
    }

    public var body: some View {
        NavigationSplitView {
            sidebar()
        } detail: {
            if let selected = selection {
                detail(selected)
            } else {
                EmptyStateView(
                    systemIcon: "sidebar.left",
                    title: "No Selection",
                    description: "Select an item from the sidebar."
                )
            }
        }
    }
}

// MARK: - Preview

private struct PreviewItem: Hashable, Identifiable {
    let id: Int
    let name: String
}

struct SplitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SplitDetailView(
            selection: .constant(nil as PreviewItem?)
        ) {
            List {
                Text("Item 1")
                Text("Item 2")
            }
        } detail: { (item: PreviewItem) in
            Text(item.name)
        }
    }
}

#endif
