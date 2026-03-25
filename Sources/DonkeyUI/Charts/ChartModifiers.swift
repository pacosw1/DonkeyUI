#if canImport(Charts)
import SwiftUI
import Charts

struct DonkeyChartStyleModifier: ViewModifier {
    @Environment(\.donkeyTheme) var theme
    let style: DonkeyChartStyle?

    func body(content: Content) -> some View {
        let s = style ?? .fromTheme(theme)
        content
            .chartXAxis(s.showAxis ? .automatic : .hidden)
            .chartYAxis(s.showAxis ? .automatic : .hidden)
            .chartLegend(s.showLegend ? .automatic : .hidden)
            .chartForegroundStyleScale(range: s.foregroundColors.map { $0.gradient })
    }
}

public extension View {
    /// Apply DonkeyTheme styling to any Chart view.
    func donkeyChartStyle(_ style: DonkeyChartStyle? = nil) -> some View {
        modifier(DonkeyChartStyleModifier(style: style))
    }
}
#endif
