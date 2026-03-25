#if canImport(Charts)
import SwiftUI
import Charts

public struct ThemedLineChart<Data: DonkeyChartable>: View {
    @Environment(\.donkeyTheme) var theme
    @State private var isAnimated = false

    let data: [Data]
    let showArea: Bool
    let showPoints: Bool
    let animate: Bool
    let style: DonkeyChartStyle?
    let height: CGFloat

    public init(
        data: [Data],
        showArea: Bool = false,
        showPoints: Bool = true,
        animate: Bool = true,
        style: DonkeyChartStyle? = nil,
        height: CGFloat = 200
    ) {
        self.data = data
        self.showArea = showArea
        self.showPoints = showPoints
        self.animate = animate
        self.style = style
        self.height = height
    }

    public var body: some View {
        let resolvedStyle = style ?? .fromTheme(theme)

        Chart(data) { item in
            LineMark(
                x: .value("Label", item.label),
                y: .value("Value", isAnimated ? item.value : 0)
            )
            .foregroundStyle(resolvedStyle.foregroundColors.first ?? theme.colors.primary)
            .interpolationMethod(.catmullRom)

            if showArea {
                AreaMark(
                    x: .value("Label", item.label),
                    y: .value("Value", isAnimated ? item.value : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            resolvedStyle.foregroundColors.first?.opacity(0.3) ?? .blue.opacity(0.3),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }

            if showPoints {
                PointMark(
                    x: .value("Label", item.label),
                    y: .value("Value", isAnimated ? item.value : 0)
                )
                .foregroundStyle(resolvedStyle.foregroundColors.first ?? theme.colors.primary)
            }
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

struct ThemedLineChart_Previews: PreviewProvider {
    static var previews: some View {
        ThemedLineChart(data: [
            DonkeyChartItem(label: "Mon", value: 10),
            DonkeyChartItem(label: "Tue", value: 25),
            DonkeyChartItem(label: "Wed", value: 18),
            DonkeyChartItem(label: "Thu", value: 32),
            DonkeyChartItem(label: "Fri", value: 28),
        ], showArea: true)
        .padding()
    }
}
#endif
