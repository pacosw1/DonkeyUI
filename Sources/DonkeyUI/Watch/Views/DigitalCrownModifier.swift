#if os(watchOS)
import SwiftUI

// MARK: - DonkeyCrownRotationModifier

public struct DonkeyCrownRotationModifier: ViewModifier {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let sensitivity: DigitalCrownRotationalSensitivity

    public func body(content: Content) -> some View {
        content
            .focusable()
            .digitalCrownRotation(
                $value,
                from: range.lowerBound,
                through: range.upperBound,
                sensitivity: sensitivity,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
    }
}

// MARK: - DonkeyCrownStepperModifier

public struct DonkeyCrownStepperModifier: ViewModifier {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double

    @State private var crownValue: Double

    public init(value: Binding<Double>, range: ClosedRange<Double>, step: Double) {
        self._value = value
        self.range = range
        self.step = step
        self._crownValue = State(initialValue: value.wrappedValue)
    }

    public func body(content: Content) -> some View {
        content
            .focusable()
            .digitalCrownRotation(
                $crownValue,
                from: range.lowerBound,
                through: range.upperBound,
                sensitivity: .low,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownValue) { _, newValue in
                let stepped = (newValue / step).rounded() * step
                let clamped = min(max(stepped, range.lowerBound), range.upperBound)
                if clamped != value {
                    value = clamped
                }
            }
    }
}

// MARK: - View Extensions

public extension View {
    /// Binds Digital Crown rotation to a value within a range, with haptic feedback.
    func donkeyCrownRotation(
        value: Binding<Double>,
        range: ClosedRange<Double>,
        sensitivity: DigitalCrownRotationalSensitivity = .medium
    ) -> some View {
        modifier(DonkeyCrownRotationModifier(
            value: value,
            range: range,
            sensitivity: sensitivity
        ))
    }

    /// Binds Digital Crown rotation to a stepped value within a range, with haptic feedback.
    func donkeyCrownStepper(
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double = 1.0
    ) -> some View {
        modifier(DonkeyCrownStepperModifier(
            value: value,
            range: range,
            step: step
        ))
    }
}

// MARK: - Preview

struct DigitalCrownModifier_Previews: PreviewProvider {
    struct Demo: View {
        @State private var volume: Double = 50
        @State private var rating: Double = 3

        var body: some View {
            VStack(spacing: 12) {
                Text("Volume: \(Int(volume))")
                    .donkeyCrownRotation(value: $volume, range: 0...100)

                Text("Rating: \(Int(rating))")
                    .donkeyCrownStepper(value: $rating, in: 1...5, step: 1)
            }
        }
    }

    static var previews: some View {
        Demo()
    }
}
#endif
