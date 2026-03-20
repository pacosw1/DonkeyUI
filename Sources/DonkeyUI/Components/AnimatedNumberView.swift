import SwiftUI

// MARK: - AnimatedNumberFormat

public enum AnimatedNumberFormat {
    case integer
    case decimal(Int)
    case currency(String)
    case percentage
    case compact
}

// MARK: - AnimatedNumberView

public struct AnimatedNumberView: View {

    public let value: Double
    public var format: AnimatedNumberFormat
    public var font: Font
    public var fontWeight: Font.Weight
    public var color: Color?

    @Environment(\.donkeyTheme) var theme

    public init(
        value: Double,
        format: AnimatedNumberFormat = .integer,
        font: Font = .title,
        fontWeight: Font.Weight = .bold,
        color: Color? = nil
    ) {
        self.value = value
        self.format = format
        self.font = font
        self.fontWeight = fontWeight
        self.color = color
    }

    public var body: some View {
        Text(formatted)
            .font(font)
            .fontWeight(fontWeight)
            .foregroundStyle(color ?? theme.colors.onBackground)
            .contentTransition(.numericText())
            .animation(.snappy, value: value)
    }

    private var formatted: String {
        switch format {
        case .integer:
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"

        case .decimal(let places):
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = places
            formatter.maximumFractionDigits = places
            return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(places)f", value)

        case .currency(let code):
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = code
            return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)

        case .percentage:
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: value / 100.0)) ?? "\(Int(value))%"

        case .compact:
            return UnitFormatter.compact(value)
        }
    }
}

// MARK: - Preview

#Preview("Animated Numbers") {
    struct DemoView: View {
        @State private var sliderValue: Double = 500

        var body: some View {
            VStack(spacing: 24) {
                Text("Drag the slider")
                    .font(.headline)

                Slider(value: $sliderValue, in: 0...100_000, step: 1)
                    .padding(.horizontal)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    label("Integer") {
                        AnimatedNumberView(value: sliderValue, format: .integer)
                    }
                    label("Decimal(2)") {
                        AnimatedNumberView(value: sliderValue, format: .decimal(2), font: .title2)
                    }
                    label("Currency") {
                        AnimatedNumberView(value: sliderValue, format: .currency("USD"), font: .title2)
                    }
                    label("Percentage") {
                        AnimatedNumberView(value: sliderValue.truncatingRemainder(dividingBy: 100), format: .percentage, font: .title2)
                    }
                    label("Compact") {
                        AnimatedNumberView(value: sliderValue, format: .compact, font: .title2)
                    }
                }
                .padding()

                Spacer()
            }
            .padding()
        }

        private func label<V: View>(_ title: String, @ViewBuilder content: () -> V) -> some View {
            VStack(spacing: 4) {
                content()
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    return DemoView()
}
