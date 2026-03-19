import SwiftUI

// MARK: - RatingPromptView

public struct RatingPromptView: View {
    let appName: String
    let onPositive: () -> Void
    let onNegative: () -> Void
    let onDismiss: () -> Void

    @Environment(\.donkeyTheme) var theme
    @State private var phase: Phase = .initial

    private enum Phase: Equatable {
        case initial
        case negative
    }

    public init(
        appName: String,
        onPositive: @escaping () -> Void,
        onNegative: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.appName = appName
        self.onPositive = onPositive
        self.onNegative = onNegative
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: theme.spacing.xl) {
            // Dismiss button
            HStack {
                Spacer()
                Button {
                    DonkeyHaptics.light()
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(theme.typography.callout)
                        .foregroundColor(theme.colors.secondary)
                        .frame(width: 32, height: 32)
                        .bgOverlay(
                            bgColor: theme.colors.secondary.opacity(0.1),
                            radius: theme.shape.radiusFull
                        )
                }
                .buttonStyle(.plain)
            }

            switch phase {
            case .initial:
                initialContent
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            case .negative:
                negativeContent
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(theme.spacing.xl)
        .bgOverlay(
            bgColor: theme.colors.surface,
            radius: theme.shape.radiusXL
        )
        .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 8)
        .padding(theme.spacing.xxl)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: phase)
    }

    // MARK: - Initial Phase

    private var initialContent: some View {
        VStack(spacing: theme.spacing.xl) {
            Text("😊")
                .font(.system(size: 56))

            VStack(spacing: theme.spacing.sm) {
                Text("Enjoying \(appName)?")
                    .font(theme.typography.title3)
                    .fontWeight(theme.typography.emphasisWeight)
                    .foregroundColor(theme.colors.onSurface)
                    .multilineTextAlignment(.center)

                Text("Your feedback helps us improve")
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: theme.spacing.md) {
                ThemedButton("Not Really", role: .secondary) {
                    DonkeyHaptics.light()
                    phase = .negative
                }

                ThemedButton("Yes, I love it!", role: .primary) {
                    DonkeyHaptics.success()
                    onPositive()
                }
            }
        }
    }

    // MARK: - Negative Phase

    private var negativeContent: some View {
        VStack(spacing: theme.spacing.xl) {
            Text("💬")
                .font(.system(size: 56))

            VStack(spacing: theme.spacing.sm) {
                Text("We'd love to hear from you")
                    .font(theme.typography.title3)
                    .fontWeight(theme.typography.emphasisWeight)
                    .foregroundColor(theme.colors.onSurface)
                    .multilineTextAlignment(.center)

                Text("Tell us how we can make \(appName) better")
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: theme.spacing.sm) {
                ThemedButton("Send Feedback", icon: "envelope", role: .primary) {
                    DonkeyHaptics.medium()
                    onNegative()
                }

                Button {
                    DonkeyHaptics.light()
                    onDismiss()
                } label: {
                    Text("No Thanks")
                        .font(theme.typography.callout)
                        .foregroundColor(theme.colors.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Preview

struct RatingPromptView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()

            RatingPromptView(
                appName: "WaterTracker",
                onPositive: {},
                onNegative: {},
                onDismiss: {}
            )
        }
    }
}
