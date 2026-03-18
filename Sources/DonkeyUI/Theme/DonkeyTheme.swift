import SwiftUI

public struct DonkeyTheme: Sendable {

    public var colors: DonkeyThemeColors
    public var typography: DonkeyThemeTypography
    public var shape: DonkeyThemeShape
    public var spacing: DonkeyThemeSpacing

    public init(
        colors: DonkeyThemeColors = DonkeyThemeColors(),
        typography: DonkeyThemeTypography = DonkeyThemeTypography(),
        shape: DonkeyThemeShape = DonkeyThemeShape(),
        spacing: DonkeyThemeSpacing = DonkeyThemeSpacing()
    ) {
        self.colors = colors
        self.typography = typography
        self.shape = shape
        self.spacing = spacing
    }
}

// MARK: - Environment Integration

private struct DonkeyThemeKey: EnvironmentKey {
    static let defaultValue = DonkeyTheme()
}

public extension EnvironmentValues {
    var donkeyTheme: DonkeyTheme {
        get { self[DonkeyThemeKey.self] }
        set { self[DonkeyThemeKey.self] = newValue }
    }
}

public extension View {
    func donkeyTheme(_ theme: DonkeyTheme) -> some View {
        environment(\.donkeyTheme, theme)
    }
}
