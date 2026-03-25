#if canImport(Charts)
import SwiftUI

public struct DonkeyChartStyle: Sendable {
    public let foregroundColors: [Color]
    public let axisColor: Color
    public let gridColor: Color
    public let labelFont: Font
    public let labelColor: Color
    public let showGrid: Bool
    public let showAxis: Bool
    public let showLegend: Bool

    public init(
        foregroundColors: [Color] = [.blue, .green, .orange, .purple, .red],
        axisColor: Color = .secondary,
        gridColor: Color = .secondary.opacity(0.2),
        labelFont: Font = .caption,
        labelColor: Color = .secondary,
        showGrid: Bool = true,
        showAxis: Bool = true,
        showLegend: Bool = true
    ) {
        self.foregroundColors = foregroundColors
        self.axisColor = axisColor
        self.gridColor = gridColor
        self.labelFont = labelFont
        self.labelColor = labelColor
        self.showGrid = showGrid
        self.showAxis = showAxis
        self.showLegend = showLegend
    }

    public static func fromTheme(_ theme: DonkeyTheme) -> DonkeyChartStyle {
        DonkeyChartStyle(
            foregroundColors: [
                theme.colors.primary,
                theme.colors.accent,
                theme.colors.success,
                theme.colors.warning,
                theme.colors.error
            ],
            axisColor: theme.colors.onSurface.opacity(0.5),
            gridColor: theme.colors.border,
            labelFont: theme.typography.caption,
            labelColor: theme.colors.onSurface,
            showGrid: true,
            showAxis: true,
            showLegend: true
        )
    }
}
#endif
