import SwiftUI

// MARK: - CountdownView

public struct CountdownView: View {
    var targetDate: Date
    var label: String?
    var onExpired: (() -> Void)?

    @Environment(\.donkeyTheme) var theme
    @State private var hasExpired: Bool = false

    public init(
        targetDate: Date,
        label: String? = nil,
        onExpired: (() -> Void)? = nil
    ) {
        self.targetDate = targetDate
        self.label = label
        self.onExpired = onExpired
    }

    public var body: some View {
        VStack(spacing: theme.spacing.sm) {
            if let label = label {
                Text(label)
                    .font(theme.typography.caption)
                    .fontWeight(theme.typography.emphasisWeight)
                    .foregroundStyle(theme.colors.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
            }

            TimelineView(.periodic(from: .now, by: 1)) { context in
                let remaining = targetDate.timeIntervalSince(context.date)

                if remaining <= 0 {
                    expiredView
                        .onAppear {
                            if !hasExpired {
                                hasExpired = true
                                onExpired?()
                            }
                        }
                } else {
                    let components = countdownComponents(from: remaining)
                    countdownDisplay(components: components)
                }
            }
        }
    }

    private func countdownDisplay(components: (days: Int, hours: Int, minutes: Int, seconds: Int)) -> some View {
        HStack(spacing: theme.spacing.sm) {
            if components.days > 0 {
                digitBlock(value: components.days, unit: "DAY")
                colonSeparator
            }

            digitBlock(value: components.hours, unit: "HR")
            colonSeparator
            digitBlock(value: components.minutes, unit: "MIN")
            colonSeparator
            digitBlock(value: components.seconds, unit: "SEC")
        }
    }

    private func digitBlock(value: Int, unit: String) -> some View {
        VStack(spacing: theme.spacing.xxs) {
            Text(String(format: "%02d", value))
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(theme.colors.onSurface)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: value)

            Text(unit)
                .font(theme.typography.caption2)
                .fontWeight(theme.typography.emphasisWeight)
                .foregroundStyle(theme.colors.secondary)
                .tracking(0.5)
        }
        .frame(minWidth: 48)
        .padding(.vertical, theme.spacing.sm)
        .padding(.horizontal, theme.spacing.sm)
        .bgOverlay(
            bgColor: theme.colors.surface,
            radius: theme.shape.radiusSmall
        )
    }

    private var colonSeparator: some View {
        Text(":")
            .font(.system(size: 24, weight: .bold, design: .monospaced))
            .foregroundStyle(theme.colors.secondary.opacity(0.5))
            .padding(.bottom, 18)
    }

    private var expiredView: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "clock.badge.xmark")
                .font(theme.typography.title3)
                .foregroundStyle(theme.colors.error)

            Text("Expired")
                .font(theme.typography.headline)
                .fontWeight(theme.typography.emphasisWeight)
                .foregroundStyle(theme.colors.error)
        }
        .padding(.vertical, theme.spacing.md)
        .padding(.horizontal, theme.spacing.xl)
        .bgOverlay(
            bgColor: theme.colors.error.opacity(0.1),
            radius: theme.shape.radiusMedium,
            borderColor: theme.colors.error.opacity(0.3),
            borderWidth: 1
        )
    }

    private func countdownComponents(from interval: TimeInterval) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let total = Int(interval)
        let days = total / 86400
        let hours = (total % 86400) / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return (days, hours, minutes, seconds)
    }
}

// MARK: - Preview

struct CountdownView_Previews: PreviewProvider {
    static let hoursAway = Date().addingTimeInterval(12820)
    static let daysAway = Date().addingTimeInterval(190600)
    static let expired = Date().addingTimeInterval(-60)
    static let minutesAway = Date().addingTimeInterval(185)

    static var previews: some View {
        VStack(spacing: 32) {
            CountdownView(targetDate: hoursAway, label: "Flash Sale Ends")
            CountdownView(targetDate: daysAway, label: "Launch Day")
            CountdownView(targetDate: expired, label: "Event")
            CountdownView(targetDate: minutesAway)
        }
        .padding()
    }
}
