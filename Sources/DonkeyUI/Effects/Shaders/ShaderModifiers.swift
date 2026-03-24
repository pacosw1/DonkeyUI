import SwiftUI

// MARK: - DonkeyShaderLibrary
//
// SPM packages must use ShaderLibrary.bundle(.module) to find Metal shaders.
// ShaderLibrary without a bundle only searches the main app bundle.

@available(iOS 17.0, macOS 14.0, *)
@dynamicMemberLookup
enum DonkeyShaderLibrary {
    static subscript(dynamicMember name: String) -> ShaderFunction {
        ShaderLibrary.bundle(.module)[dynamicMember: name]
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// MARK: - Shimmer / Shine Sweep
// ═══════════════════════════════════════════════════════════════════════════

@available(iOS 17.0, macOS 14.0, *)
private struct ShimmerShaderModifier: ViewModifier {
    let isActive: Bool
    let duration: Double
    let gradientWidth: Double
    let maxLightness: Double

    @State private var startDate = Date()

    func body(content: Content) -> some View {
        if isActive {
            TimelineView(.animation) { timeline in
                let elapsed = startDate.distance(to: timeline.date)
                content.visualEffect { view, proxy in
                    view.colorEffect(
                        DonkeyShaderLibrary.shimmer(
                            .float2(proxy.size),
                            .float(elapsed),
                            .float(duration),
                            .float(gradientWidth),
                            .float(maxLightness)
                        )
                    )
                }
            }
        } else {
            content
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// MARK: - Public View Extensions
// ═══════════════════════════════════════════════════════════════════════════

@available(iOS 17.0, macOS 14.0, *)
public extension View {

    /// Diagonal shine sweep effect. Perfect for premium buttons, badges, CTAs, and paywalls.
    ///
    /// Uses an HSL lightness boost for a natural, polished look on any color.
    ///
    /// ```swift
    /// Text("PRO").donkeyShimmer()
    /// Button("Upgrade") { }.donkeyShimmer(maxLightness: 0.8)
    /// ThemedButton("Subscribe", role: .primary) { }.donkeyShimmer(duration: 3)
    /// ```
    func donkeyShimmer(
        isActive: Bool = true,
        duration: Double = 2.0,
        gradientWidth: Double = 0.3,
        maxLightness: Double = 0.5
    ) -> some View {
        modifier(ShimmerShaderModifier(
            isActive: isActive, duration: duration,
            gradientWidth: gradientWidth, maxLightness: maxLightness
        ))
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ═══════════════════════════════════════════════════════════════════════════

@available(iOS 17.0, macOS 14.0, *)
#Preview("Shimmer Effect") {
    VStack(spacing: 24) {
        Text("Shimmer Effect")
            .font(.largeTitle).bold()

        Text("PREMIUM")
            .font(.title.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(.blue)
            .clipShape(Capsule())
            .donkeyShimmer()

        Text("UPGRADE NOW")
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.purple.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 40)
            .donkeyShimmer(duration: 3, maxLightness: 0.6)

        Text("Subscribe for $4.99/mo")
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(.green)
            .clipShape(Capsule())
            .donkeyShimmer(gradientWidth: 0.2, maxLightness: 0.4)
    }
    .padding()
}
