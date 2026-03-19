import SwiftUI

// MARK: - SkeletonModifier

public struct SkeletonModifier: ViewModifier {
    let isLoading: Bool

    @State private var phase: CGFloat = 0

    public func body(content: Content) -> some View {
        if isLoading {
            content
                .redacted(reason: .placeholder)
                .overlay(
                    GeometryReader { geo in
                        let width = geo.size.width
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.white.opacity(0.4),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: width * 0.6)
                        .offset(x: -width * 0.6 + phase * (width * 1.6))
                    }
                    .clipped()
                )
                .disabled(true)
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}

public extension View {
    func skeleton(isLoading: Bool) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading))
    }
}

// MARK: - SkeletonRow

public struct SkeletonRow: View {
    let lineCount: Int

    @Environment(\.donkeyTheme) var theme
    @State private var phase: CGFloat = 0

    public init(lineCount: Int = 2) {
        self.lineCount = max(1, min(lineCount, 3))
    }

    public var body: some View {
        HStack(spacing: theme.spacing.md) {
            // Avatar placeholder
            Circle()
                .fill(theme.colors.surface)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                // Title line
                RoundedRectangle(cornerRadius: theme.shape.radiusSmall)
                    .fill(theme.colors.surface)
                    .frame(height: 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(width: randomWidth(index: 0))

                if lineCount >= 2 {
                    RoundedRectangle(cornerRadius: theme.shape.radiusSmall)
                        .fill(theme.colors.surface)
                        .frame(height: 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(width: randomWidth(index: 1))
                }

                if lineCount >= 3 {
                    RoundedRectangle(cornerRadius: theme.shape.radiusSmall)
                        .fill(theme.colors.surface)
                        .frame(height: 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(width: randomWidth(index: 2))
                }
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .padding(.horizontal, theme.spacing.lg)
        .overlay(shimmerOverlay)
        .clipShape(RoundedRectangle(cornerRadius: theme.shape.radiusMedium))
        .onAppear {
            withAnimation(
                .linear(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                phase = 1
            }
        }
    }

    private var shimmerOverlay: some View {
        GeometryReader { geo in
            let width = geo.size.width
            LinearGradient(
                colors: [
                    .clear,
                    Color.white.opacity(0.3),
                    .clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: width * 0.5)
            .offset(x: -width * 0.5 + phase * (width * 1.5))
        }
        .clipped()
    }

    private func randomWidth(index: Int) -> CGFloat {
        switch index {
        case 0: return 180
        case 1: return 140
        default: return 100
        }
    }
}

// MARK: - Preview

struct SkeletonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Skeleton modifier on text
            Text("Loading content here...")
                .font(.headline)
                .skeleton(isLoading: true)

            Divider()

            // Skeleton rows
            SkeletonRow(lineCount: 1)
            SkeletonRow(lineCount: 2)
            SkeletonRow(lineCount: 3)

            Divider()

            // Not loading
            Text("Visible content")
                .font(.headline)
                .skeleton(isLoading: false)
        }
        .padding()
    }
}
