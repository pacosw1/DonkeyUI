#if canImport(Charts)
import SwiftUI
import Charts

public struct ThemedAreaChart<Data: DonkeyChartable>: View {
    @Environment(\.donkeyTheme) var theme
    @State private var isAnimated = false

    let data: [Data]
    let interpolation: InterpolationMethod
    let animate: Bool
    let style: DonkeyChartStyle?
    let height: CGFloat

    public init(
        data: [Data],
        interpolation: InterpolationMethod = .catmullRom,
        animate: Bool = true,
        style: DonkeyChartStyle? = nil,
        height: CGFloat = 200
    ) {
        self.data = data
        self.interpolation = interpolation
        self.animate = animate
        self.style = style
        self.height = height
    }

    public var body: some View {
        let resolvedStyle = style ?? .fromTheme(theme)
        let color = resolvedStyle.foregroundColors.first ?? theme.colors.primary

        Chart(data) { item in
            AreaMark(
                x: .value("Label", item.label),
                y: .value("Value", isAnimated ? item.value : 0)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [color.opacity(0.3), color.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(interpolation)

            LineMark(
                x: .value("Label", item.label),
                y: .value("Value", isAnimated ? item.value : 0)
            )
            .foregroundStyle(color)
            .interpolationMethod(interpolation)
        }
        .chartXAxis(resolvedStyle.showAxis ? .automatic : .hidden)
        .chartYAxis(resolvedStyle.showAxis ? .automatic : .hidden)
        .frame(height: height)
        .onAppear {
            if animate {
                withAnimation(.easeOut(duration: 0.6)) { isAnimated = true }
            } else {
                isAnimated = true
            }
        }
    }
}

// MARK: - Preview

struct ThemedAreaChart_Previews: PreviewProvider {
    static var previews: some View {
        ThemedAreaChart(data: [
            DonkeyChartItem(label: "Jan", value: 50),
            DonkeyChartItem(label: "Feb", value: 80),
            DonkeyChartItem(label: "Mar", value: 60),
            DonkeyChartItem(label: "Apr", value: 120),
            DonkeyChartItem(label: "May", value: 95),
        ])
        .padding()
    }
}
#endif
