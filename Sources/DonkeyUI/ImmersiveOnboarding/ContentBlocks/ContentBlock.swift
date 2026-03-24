import SwiftUI

// MARK: - RevealStyle

/// Animation style for revealing a content block during immersive onboarding.
public enum RevealStyle: Sendable {
    case fadeIn
    case typewriter(charactersPerSecond: Double = 40)
    case wordByWord(interval: Duration = .milliseconds(120))
    case slideUp
    case slideFromLeading
    case slideFromTrailing
    case scaleIn
}

// MARK: - RevealTiming

/// Timing configuration for a content block's reveal animation.
public struct RevealTiming: Sendable {

    /// Delay after the previous block finishes before this one starts.
    /// Use negative values to overlap with the previous block (stagger effect).
    public var delay: Duration

    /// Duration of the reveal animation.
    /// For `.typewriter` and `.wordByWord`, this is ignored -- duration is computed from content length.
    public var duration: Duration

    /// The visual style of the reveal.
    public var style: RevealStyle

    public init(
        delay: Duration = .zero,
        duration: Duration = .seconds(0.6),
        style: RevealStyle = .fadeIn
    ) {
        self.delay = delay
        self.duration = duration
        self.style = style
    }

    // MARK: Presets

    /// Standard fade-in (0.6s)
    public static var standard: RevealTiming {
        RevealTiming()
    }

    /// Slow fade-in (1.2s)
    public static var slow: RevealTiming {
        RevealTiming(duration: .seconds(1.2))
    }

    /// Typewriter text reveal (40 characters/second)
    public static var typewriter: RevealTiming {
        RevealTiming(style: .typewriter())
    }

    /// Slide up with fade (0.5s)
    public static var slideUp: RevealTiming {
        RevealTiming(delay: .seconds(0.1), duration: .seconds(0.5), style: .slideUp)
    }

    /// Scale in with fade (0.8s)
    public static var scaleIn: RevealTiming {
        RevealTiming(duration: .seconds(0.8), style: .scaleIn)
    }
}

// MARK: - ContentBlock Protocol

/// A content block that can be progressively revealed in an immersive onboarding section.
public protocol ContentBlock: Identifiable, View {
    var id: String { get }
    var timing: RevealTiming { get }

    /// Estimated total duration for this block's reveal, including content-dependent time.
    /// For fixed animations this equals `timing.duration`.
    /// For text-based reveals this is computed from the text length.
    var estimatedDuration: Duration { get }
}

public extension ContentBlock {
    var estimatedDuration: Duration { timing.duration }
}
