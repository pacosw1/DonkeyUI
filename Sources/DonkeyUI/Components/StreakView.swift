//
//  StreakView.swift
//  DonkeyUI
//
//  Animated streak counter with flame icon.
//

import SwiftUI

/// An animated streak display showing a flame icon and numeric count.
///
/// The flame pulses when the streak value changes, and the number
/// transitions with a numeric text animation.
///
/// ```swift
/// StreakView(streak: 12, size: 16, activeColor: .orange, inactiveColor: .gray)
/// ```
///
/// - Parameters:
///   - streak: The current streak count.
///   - size: Font size for the flame icon (default 14).
///   - activeColor: Color when streak > 0 (default orange `#EE9144`).
///   - inactiveColor: Color when streak is 0 (default `.gray`).
public struct StreakView: View {

    // MARK: - Properties

    public let streak: Int
    public var size: CGFloat
    public var activeColor: Color
    public var inactiveColor: Color

    private var isEmpty: Bool { streak <= 0 }

    private var flameColor: Color {
        isEmpty ? inactiveColor : activeColor
    }

    private var textColor: AnyShapeStyle {
        isEmpty ? AnyShapeStyle(inactiveColor) : AnyShapeStyle(.secondary)
    }

    // MARK: - Init

    /// Creates a streak view.
    /// - Parameters:
    ///   - streak: The current streak count.
    ///   - size: Font size for the flame icon.
    ///   - activeColor: Color used when streak is greater than zero.
    ///   - inactiveColor: Color used when streak is zero.
    public init(
        streak: Int,
        size: CGFloat = 14,
        activeColor: Color = Color(red: 238/255, green: 145/255, blue: 68/255),
        inactiveColor: Color = .gray
    ) {
        self.streak = streak
        self.size = size
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
    }

    // MARK: - Body

    public var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(systemName: "flame.fill")
                .foregroundStyle(flameColor)
                .font(.system(size: size))
                .symbolEffect(.pulse, options: .speed(1), value: streak)

            Text(streak, format: .number)
                .contentTransition(.numericText())
                .fontWeight(.bold)
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(textColor)
        }
    }
}

// MARK: - Preview

#Preview("Streak View") {
    VStack(spacing: 20) {
        StreakView(streak: 0)
        StreakView(streak: 5)
        StreakView(streak: 42, size: 20, activeColor: .red)
        StreakView(streak: 100, size: 24, activeColor: .green, inactiveColor: .gray.opacity(0.3))
    }
    .padding()
}
