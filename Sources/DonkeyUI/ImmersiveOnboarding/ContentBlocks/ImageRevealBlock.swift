import SwiftUI

// MARK: - ImageSource

/// Source for an image in an onboarding block.
public enum OnboardingImageSource: Sendable {
    case asset(String)
    case system(String, Color)
}

// MARK: - ImageRevealBlock

/// An image block that reveals with a fade/scale animation.
public struct ImageRevealBlock: ContentBlock, View {
    public let id: String
    public let source: OnboardingImageSource
    public let maxHeight: CGFloat
    public let cornerRadius: CGFloat?
    public let timing: RevealTiming

    @Environment(\.donkeyTheme) private var theme
    @Environment(\.immersiveRevealProgress) private var progress: Double

    public init(
        id: String = UUID().uuidString,
        _ source: OnboardingImageSource,
        maxHeight: CGFloat = 240,
        cornerRadius: CGFloat? = nil,
        timing: RevealTiming = .scaleIn
    ) {
        self.id = id
        self.source = source
        self.maxHeight = maxHeight
        self.cornerRadius = cornerRadius
        self.timing = timing
    }

    public var body: some View {
        imageContent
            .modifier(RevealModifier(progress: progress, style: timing.style))
    }

    @ViewBuilder
    private var imageContent: some View {
        switch source {
        case .asset(let name):
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: maxHeight)
                .clipShape(RoundedRectangle(
                    cornerRadius: cornerRadius ?? theme.shape.radiusMedium,
                    style: .continuous
                ))

        case .system(let name, let color):
            Image(systemName: name)
                .font(.system(size: 64))
                .fontWeight(.light)
                .foregroundStyle(color)
                .frame(width: 120, height: 120)
                .bgOverlay(
                    bgColor: color.opacity(0.1),
                    radius: theme.shape.radiusXL
                )
        }
    }
}

// MARK: - RevealModifier

/// Applies reveal animation transforms based on the current progress and style.
struct RevealModifier: ViewModifier {
    let progress: Double
    let style: RevealStyle

    func body(content: Content) -> some View {
        switch style {
        case .fadeIn:
            content.opacity(progress)

        case .typewriter, .wordByWord:
            // Text blocks handle their own visibility; don't double-fade.
            content

        case .slideUp:
            content
                .opacity(progress)
                .offset(y: (1 - progress) * 30)

        case .slideFromLeading:
            content
                .opacity(progress)
                .offset(x: (1 - progress) * -40)

        case .slideFromTrailing:
            content
                .opacity(progress)
                .offset(x: (1 - progress) * 40)

        case .scaleIn:
            content
                .opacity(progress)
                .scaleEffect(0.6 + 0.4 * progress)
        }
    }
}
