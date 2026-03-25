#if canImport(WidgetKit)
import SwiftUI
import WidgetKit

/// Static theme for widgets since they can't use @Environment.
public struct DonkeyWidgetTheme: Sendable {
    public var colors: DonkeyThemeColors
    public var typography: DonkeyThemeTypography
    public var shape: DonkeyThemeShape
    public var spacing: DonkeyThemeSpacing

    public init(from theme: DonkeyTheme = DonkeyTheme()) {
        self.colors = theme.colors
        self.typography = theme.typography
        self.shape = theme.shape
        self.spacing = theme.spacing
    }

    public static let `default` = DonkeyWidgetTheme()
}

// MARK: - Container Background

public extension View {
    /// Applies a container background color for the widget.
    func donkeyContainerBackground(_ color: Color) -> some View {
        containerBackground(color, for: .widget)
    }
}
#endif
