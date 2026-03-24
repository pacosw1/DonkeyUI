import SwiftUI

// MARK: - Wave Text Renderer

/// A TextRenderer that animates each character with a sine-wave vertical offset.
/// Creates a fluid, ripple-like motion across the text -- great for titles,
/// achievement text, or any moment you want to delight the user.
///
/// Usage:
/// ```swift
/// Text("Welcome!")
///     .donkeyWaveText(isActive: true)
///
/// // Or manual control:
/// Text("Hello World")
///     .textRenderer(DonkeyWaveRenderer(phase: animationValue))
/// ```
///
/// Requires iOS 18+ / macOS 15+. Falls back to static text on older versions.
@available(iOS 18.0, macOS 15.0, *)
public struct DonkeyWaveRenderer: TextRenderer, Animatable {

    /// The wave phase -- animate this for continuous motion.
    public var phase: Double

    /// Vertical strength of the wave in points.
    public var strength: Double

    /// Spatial frequency -- higher = tighter wave pattern.
    public var frequency: Double

    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    public init(phase: Double = 0, strength: Double = 4, frequency: Double = 0.4) {
        self.phase = phase
        self.strength = strength
        self.frequency = frequency
    }

    public func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for line in layout {
            for run in line {
                for (index, glyph) in run.enumerated() {
                    var glyphContext = context
                    let yOffset = strength * sin(Double(index) * frequency + phase)
                    glyphContext.translateBy(x: 0, y: yOffset)
                    glyphContext.draw(glyph, options: .disablesSubpixelQuantization)
                }
            }
        }
    }
}

// MARK: - Typewriter Text Renderer

/// A TextRenderer that reveals text character-by-character with a subtle
/// fade + slide-up effect per glyph. More polished than simple string truncation.
///
/// Usage:
/// ```swift
/// Text("This text reveals beautifully")
///     .textRenderer(DonkeyTypewriterRenderer(progress: 0.5))
/// ```
@available(iOS 18.0, macOS 15.0, *)
public struct DonkeyTypewriterRenderer: TextRenderer, Animatable {

    /// Reveal progress from 0.0 (no text) to 1.0 (all text).
    public var progress: Double

    public var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    public init(progress: Double = 1.0) {
        self.progress = progress
    }

    public func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        var glyphIndex = 0
        var totalGlyphs = 0

        // First pass: count glyphs
        for line in layout {
            for run in line {
                totalGlyphs += run.count
            }
        }

        let visibleCount = Int(progress * Double(totalGlyphs))

        // Second pass: draw with per-glyph effects
        for line in layout {
            for run in line {
                for glyph in run {
                    if glyphIndex < visibleCount {
                        // Visible: draw at full opacity
                        context.draw(glyph)
                    } else if glyphIndex == visibleCount {
                        // Currently revealing: fade + slide up
                        let revealFraction = (progress * Double(totalGlyphs)) - Double(glyphIndex)
                        var glyphContext = context
                        glyphContext.opacity = revealFraction
                        glyphContext.translateBy(x: 0, y: (1 - revealFraction) * 6)
                        glyphContext.draw(glyph, options: .disablesSubpixelQuantization)
                    }
                    // else: not yet visible, skip
                    glyphIndex += 1
                }
            }
        }
    }
}

// MARK: - Shimmer Text Renderer

/// A TextRenderer that applies a horizontal shimmer/highlight sweep across text.
/// Perfect for loading states or drawing attention to text.
@available(iOS 18.0, macOS 15.0, *)
public struct DonkeyShimmerRenderer: TextRenderer, Animatable {

    /// The horizontal position of the shimmer highlight (0...1).
    public var position: Double

    /// Width of the shimmer band relative to total text width (0...1).
    public var width: Double

    public var animatableData: Double {
        get { position }
        set { position = newValue }
    }

    public init(position: Double = 0, width: Double = 0.3) {
        self.position = position
        self.width = width
    }

    public func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for line in layout {
            for run in line {
                for (index, glyph) in run.enumerated() {
                    let glyphFraction = Double(index) / max(1, Double(run.count - 1))
                    let distance = abs(glyphFraction - position)
                    let highlight = max(0, 1 - distance / width)
                    var glyphContext = context
                    glyphContext.opacity = 0.5 + 0.5 * highlight
                    glyphContext.draw(glyph)
                }
            }
        }
    }
}

// MARK: - View Extensions

@available(iOS 18.0, macOS 15.0, *)
public extension View {

    /// Applies a continuous wave animation to all Text in this view.
    /// Great for titles, achievements, and celebration moments.
    ///
    /// - Parameters:
    ///   - isActive: When true, the wave animates continuously. When false, text is static.
    ///   - strength: Vertical wave amplitude in points. Default 4.
    ///   - frequency: Spatial frequency of the wave. Default 0.4.
    ///   - speed: Animation speed. Default 3.0.
    func donkeyWaveText(
        isActive: Bool = true,
        strength: Double = 4,
        frequency: Double = 0.4,
        speed: Double = 3.0
    ) -> some View {
        modifier(WaveTextModifier(
            isActive: isActive,
            strength: strength,
            frequency: frequency,
            speed: speed
        ))
    }

    /// Applies a continuous shimmer sweep to all Text in this view.
    ///
    /// - Parameters:
    ///   - isActive: When true, shimmer animates. When false, text is static.
    ///   - speed: Seconds per sweep cycle. Default 2.0.
    func donkeyShimmerText(
        isActive: Bool = true,
        speed: Double = 2.0
    ) -> some View {
        modifier(ShimmerTextModifier(isActive: isActive, speed: speed))
    }
}

// MARK: - Internal Modifiers

@available(iOS 18.0, macOS 15.0, *)
private struct WaveTextModifier: ViewModifier {
    let isActive: Bool
    let strength: Double
    let frequency: Double
    let speed: Double

    @State private var phase: Double = 0

    func body(content: Content) -> some View {
        content
            .textRenderer(DonkeyWaveRenderer(
                phase: phase,
                strength: isActive ? strength : 0,
                frequency: frequency
            ))
            .onAppear {
                if isActive {
                    withAnimation(.linear(duration: 2.0 / speed).repeatForever(autoreverses: false)) {
                        phase = .pi * 2
                    }
                }
            }
            .onChange(of: isActive) { _, active in
                if active {
                    phase = 0
                    withAnimation(.linear(duration: 2.0 / speed).repeatForever(autoreverses: false)) {
                        phase = .pi * 2
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.3)) {
                        phase = 0
                    }
                }
            }
    }
}

@available(iOS 18.0, macOS 15.0, *)
private struct ShimmerTextModifier: ViewModifier {
    let isActive: Bool
    let speed: Double

    @State private var position: Double = -0.3

    func body(content: Content) -> some View {
        content
            .textRenderer(DonkeyShimmerRenderer(position: position))
            .onAppear {
                if isActive {
                    withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                        position = 1.3
                    }
                }
            }
    }
}

// MARK: - Previews

@available(iOS 18.0, macOS 15.0, *)
#Preview("Wave Text") {
    VStack(spacing: 32) {
        Text("Welcome to DonkeyGo!")
            .font(.largeTitle)
            .fontWeight(.bold)
            .donkeyWaveText()

        Text("Achievement Unlocked")
            .font(.title)
            .foregroundStyle(.orange)
            .donkeyWaveText(strength: 6, frequency: 0.3, speed: 2)

        Text("Loading your data...")
            .font(.headline)
            .foregroundStyle(.secondary)
            .donkeyShimmerText()
    }
    .padding()
}
