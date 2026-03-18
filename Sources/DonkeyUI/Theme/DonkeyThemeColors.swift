import SwiftUI

public struct DonkeyThemeColors: Sendable {

    public var primary: Color
    public var secondary: Color
    public var accent: Color

    public var background: Color
    public var surface: Color
    public var surfaceElevated: Color

    public var onPrimary: Color
    public var onSurface: Color
    public var onBackground: Color

    public var success: Color
    public var warning: Color
    public var error: Color
    public var destructive: Color

    public var border: Color
    public var borderSubtle: Color

    public init(
        primary: Color = .accentColor,
        secondary: Color = .secondary,
        accent: Color = .accentColor,
        background: Color? = nil,
        surface: Color? = nil,
        surfaceElevated: Color? = nil,
        onPrimary: Color = .white,
        onSurface: Color? = nil,
        onBackground: Color? = nil,
        success: Color = .green,
        warning: Color = .orange,
        error: Color = .red,
        destructive: Color = .red,
        border: Color? = nil,
        borderSubtle: Color? = nil
    ) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.onPrimary = onPrimary
        self.success = success
        self.warning = warning
        self.error = error
        self.destructive = destructive

        #if canImport(UIKit)
        self.background = background ?? Color(uiColor: .systemBackground)
        self.surface = surface ?? Color(uiColor: .secondarySystemBackground)
        self.surfaceElevated = surfaceElevated ?? Color(uiColor: .tertiarySystemBackground)
        self.onSurface = onSurface ?? Color(uiColor: .label)
        self.onBackground = onBackground ?? Color(uiColor: .label)
        self.border = border ?? Color(uiColor: .separator)
        self.borderSubtle = borderSubtle ?? Color(uiColor: .quaternarySystemFill)
        #else
        self.background = background ?? Color(nsColor: .windowBackgroundColor)
        self.surface = surface ?? Color(nsColor: .controlBackgroundColor)
        self.surfaceElevated = surfaceElevated ?? Color(nsColor: .underPageBackgroundColor)
        self.onSurface = onSurface ?? Color(nsColor: .labelColor)
        self.onBackground = onBackground ?? Color(nsColor: .labelColor)
        self.border = border ?? Color(nsColor: .separatorColor)
        self.borderSubtle = borderSubtle ?? Color(nsColor: .quaternaryLabelColor)
        #endif
    }
}
