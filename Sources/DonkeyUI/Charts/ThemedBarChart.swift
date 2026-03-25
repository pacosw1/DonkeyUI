#if canImport(Charts)
import SwiftUI
import Charts

public struct ThemedBarChart<Data: DonkeyChartable>: View {
    @Environment(\.donkeyTheme) var theme
    @State private var isAnimated = false

    let data: [Data]
    let showValues: Bool
    let animate: Bool
    let style: DonkeyChartStyle?
    let height: CGFloat

    public init(
        data: [Data],
        showValues: Bool = false,
        animate: Bool = true,
        style: DonkeyChartStyle? = nil,
        height: CGFloat = 200
    ) {
        self.data = data
        self.showValues = showValues
        self.animate = animate
        self.style = style
        self.height = height
    }

    public var body: some View {
        let resolvedStyle = style ?? .fromTheme(theme)

        Chart(data) { item in
            BarMark(
                x: .value("Label", item.label),
                y: .value("Value", isAnimated ? item.value : 0)
            )
            .foregroundStyle(resolvedStyle.foregroundColors.first ?? theme.colors.primary)
            .clipShape(.rect(cornerRadius: theme.shape.radiusSmall))

            if showValues {
                BarMark(
                    x: .value("Label", item.label),
                    y: .value("Value", isAnimated ? item.value : 0)
                )
                .annotation(position: .top) {
                    Text(String(format: "%.0f", item.value))
                        .font(resolvedStyle.labelFont)
                        .foregroundStyle(resolvedStyle.labelColor)
                }
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

struct ThemedBarChart_Previews: PreviewProvider {
    static var previews: some View {
        ThemedBarChart(data: [
            DonkeyChartItem(label: "Jan", value: 120),
            DonkeyChartItem(label: "Feb", value: 80),
            DonkeyChartItem(label: "Mar", value: 200),
            DonkeyChartItem(label: "Apr", value: 160),
        ])
        .padding()
    }
}
#endif
