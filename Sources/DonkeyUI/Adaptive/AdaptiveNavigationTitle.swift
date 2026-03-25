import SwiftUI

#if os(iOS)

// MARK: - AdaptiveNavigationTitleModifier

/// Applies different navigation title display modes based on horizontal size class.
private struct AdaptiveNavigationTitleModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var sizeClass

    let title: String
    let compactMode: NavigationBarItem.TitleDisplayMode
    let regularMode: NavigationBarItem.TitleDisplayMode

    func body(content: Content) -> some View {
        let mode = sizeClass == .compact ? compactMode : regularMode
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(mode)
    }
}

// MARK: - View Extension

public extension View {
    /// Sets the navigation title with different display modes for compact and regular size classes.
    func donkeyNavigationTitle(
        _ title: String,
        compactMode: NavigationBarItem.TitleDisplayMode = .large,
        regularMode: NavigationBarItem.TitleDisplayMode = .inline
    ) -> some View {
        modifier(AdaptiveNavigationTitleModifier(
            title: title,
            compactMode: compactMode,
            regularMode: regularMode
        ))
    }
}

#endif
