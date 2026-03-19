import SwiftUI

// MARK: - BadgeCountModifier

public struct BadgeCountModifier: ViewModifier {
    let count: Int

    @Environment(\.donkeyTheme) var theme

    public func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if count > 0 {
                    badgeLabel
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: count)
                }
            }
    }

    private var badgeLabel: some View {
        Text(displayCount)
            .font(theme.typography.caption2)
            .fontWeight(theme.typography.heavyWeight)
            .foregroundColor(.white)
            .padding(.horizontal, count > 9 ? 6 : 0)
            .frame(minWidth: 20, minHeight: 20)
            .bgOverlay(
                bgColor: theme.colors.error,
                radius: theme.shape.radiusFull
            )
            .offset(x: 8, y: -8)
    }

    private var displayCount: String {
        count > 99 ? "99+" : "\(count)"
    }
}

// MARK: - View Extension

public extension View {
    func badgeCount(_ count: Int) -> some View {
        modifier(BadgeCountModifier(count: count))
    }
}

// MARK: - Preview

struct BadgeCountView_Previews: PreviewProvider {
    struct Demo: View {
        @State private var count = 3

        var body: some View {
            VStack(spacing: 40) {
                HStack(spacing: 40) {
                    Image(systemName: "bell.fill")
                        .font(.title)
                        .badgeCount(count)

                    Image(systemName: "envelope.fill")
                        .font(.title)
                        .badgeCount(12)

                    Image(systemName: "cart.fill")
                        .font(.title)
                        .badgeCount(150)

                    Image(systemName: "heart.fill")
                        .font(.title)
                        .badgeCount(0)
                }

                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "message.fill")
                            .foregroundColor(.blue)
                    }
                    .badgeCount(count)

                Stepper("Count: \(count)", value: $count, in: 0...200)
                    .padding(.horizontal)
            }
        }
    }

    static var previews: some View {
        Demo()
    }
}
