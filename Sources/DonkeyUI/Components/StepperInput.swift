import SwiftUI

// MARK: - StepperInput

public struct StepperInput: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let label: String?

    @Environment(\.donkeyTheme) var theme

    public init(
        value: Binding<Int>,
        range: ClosedRange<Int> = 0...100,
        step: Int = 1,
        label: String? = nil
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.label = label
    }

    private var canDecrement: Bool {
        value - step >= range.lowerBound
    }

    private var canIncrement: Bool {
        value + step <= range.upperBound
    }

    public var body: some View {
        VStack(spacing: theme.spacing.sm) {
            if let label = label {
                Text(label)
                    .font(theme.typography.subheadline)
                    .foregroundStyle(theme.colors.secondary)
            }

            HStack(spacing: 0) {
                // Minus button
                Button {
                    guard canDecrement else { return }
                    DonkeyHaptics.light()
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        value = max(value - step, range.lowerBound)
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(theme.typography.headline)
                        .fontWeight(theme.typography.emphasisWeight)
                        .foregroundStyle(canDecrement ? theme.colors.primary : theme.colors.secondary.opacity(0.4))
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.plain)
                .disabled(!canDecrement)

                // Value display
                Text("\(value)")
                    .font(theme.typography.title2)
                    .fontWeight(theme.typography.heavyWeight)
                    .foregroundStyle(theme.colors.onSurface)
                    .frame(minWidth: 64)
                    .contentTransition(.numericText())

                // Plus button
                Button {
                    guard canIncrement else { return }
                    DonkeyHaptics.light()
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        value = min(value + step, range.upperBound)
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(theme.typography.headline)
                        .fontWeight(theme.typography.emphasisWeight)
                        .foregroundStyle(canIncrement ? theme.colors.primary : theme.colors.secondary.opacity(0.4))
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.plain)
                .disabled(!canIncrement)
            }
            .bgOverlay(
                bgColor: theme.colors.surface,
                radius: theme.shape.radiusFull,
                borderColor: theme.colors.border,
                borderWidth: 1
            )
        }
    }
}

// MARK: - Preview

struct StepperInput_Previews: PreviewProvider {
    struct Demo: View {
        @State private var quantity = 3
        @State private var servings = 2
        @State private var temperature = 20

        var body: some View {
            VStack(spacing: 32) {
                StepperInput(value: $quantity, range: 1...10, label: "Quantity")
                StepperInput(value: $servings, range: 1...8, step: 1, label: "Servings")
                StepperInput(value: $temperature, range: -10...40, step: 5, label: "Temperature")
                StepperInput(value: $quantity, range: 0...99)
            }
            .padding()
        }
    }

    static var previews: some View {
        Demo()
    }
}
