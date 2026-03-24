import SwiftUI

// MARK: - Appear Animation Modifier

/// Animates a view's appearance with configurable style, delay, and animation curve.
/// Triggers once when the view first appears on screen.
@available(iOS 17.0, macOS 14.0, *)
private struct AppearAnimationModifier: ViewModifier {
    let style: AppearStyle
    let delay: Double
    let animation: Animation

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .modifier(AppearTransform(style: style, isVisible: hasAppeared))
            .onAppear {
                if delay > 0 {
                    withAnimation(animation.delay(delay)) {
                        hasAppeared = true
                    }
                } else {
                    withAnimation(animation) {
                        hasAppeared = true
                    }
                }
            }
    }
}

// MARK: - Appear Style

/// Visual style for view appearance animations.
public enum AppearStyle: Sendable {
    /// Fades in from transparent.
    case fade
    /// Slides up from below with fade.
    case slideUp(distance: CGFloat = 20)
    /// Slides down from above with fade.
    case slideDown(distance: CGFloat = 20)
    /// Slides in from the leading edge with fade.
    case slideLeading(distance: CGFloat = 30)
    /// Slides in from the trailing edge with fade.
    case slideTrailing(distance: CGFloat = 30)
    /// Scales up from a smaller size with fade.
    case scale(from: CGFloat = 0.8)
    /// Scales up with a slight bounce.
    case pop(from: CGFloat = 0.5)
    /// Slides up + scales slightly (card-like entrance).
    case cardEntrance
    /// Blurs in from a blurred state.
    case blur(radius: CGFloat = 10)
}

// MARK: - Appear Transform

/// Applies the visual transform for a given appear style and visibility state.
@available(iOS 17.0, macOS 14.0, *)
private struct AppearTransform: ViewModifier {
    let style: AppearStyle
    let isVisible: Bool

    func body(content: Content) -> some View {
        switch style {
        case .fade:
            content
                .opacity(isVisible ? 1 : 0)

        case .slideUp(let distance):
            content
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : distance)

        case .slideDown(let distance):
            content
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : -distance)

        case .slideLeading(let distance):
            content
                .opacity(isVisible ? 1 : 0)
                .offset(x: isVisible ? 0 : -distance)

        case .slideTrailing(let distance):
            content
                .opacity(isVisible ? 1 : 0)
                .offset(x: isVisible ? 0 : distance)

        case .scale(let from):
            content
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : from)

        case .pop(let from):
            content
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : from)

        case .cardEntrance:
            content
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 15)
                .scaleEffect(isVisible ? 1 : 0.95)

        case .blur(let radius):
            content
                .opacity(isVisible ? 1 : 0)
                .blur(radius: isVisible ? 0 : radius)
        }
    }
}

// MARK: - Staggered Appear Modifier

/// Animates a view's appearance with a stagger delay based on its index in a list.
/// Perfect for animating items in a ForEach, VStack, or LazyVStack.
@available(iOS 17.0, macOS 14.0, *)
private struct StaggeredAppearModifier: ViewModifier {
    let index: Int
    let style: AppearStyle
    let baseDelay: Double
    let staggerInterval: Double
    let animation: Animation

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .modifier(AppearTransform(style: style, isVisible: hasAppeared))
            .onAppear {
                let totalDelay = baseDelay + Double(index) * staggerInterval
                withAnimation(animation.delay(totalDelay)) {
                    hasAppeared = true
                }
            }
    }
}

// MARK: - View Extensions

@available(iOS 17.0, macOS 14.0, *)
public extension View {

    /// Animates this view's appearance with the given style when it first appears.
    ///
    /// ```swift
    /// Text("Hello")
    ///     .donkeyAppear(.slideUp())
    ///
    /// Image("hero")
    ///     .donkeyAppear(.scale(), delay: 0.3)
    ///
    /// CardView()
    ///     .donkeyAppear(.cardEntrance, animation: .bouncySpring)
    /// ```
    func donkeyAppear(
        _ style: AppearStyle = .fade,
        delay: Double = 0,
        animation: Animation = .smoothSpring
    ) -> some View {
        modifier(AppearAnimationModifier(
            style: style,
            delay: delay,
            animation: animation
        ))
    }

    /// Animates this view's appearance with a stagger delay based on its index.
    /// Use inside `ForEach` for cascading entrance animations.
    ///
    /// ```swift
    /// ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
    ///     ItemRow(item: item)
    ///         .donkeyStagger(index: index, style: .slideUp())
    /// }
    /// ```
    func donkeyStagger(
        index: Int,
        style: AppearStyle = .slideUp(),
        baseDelay: Double = 0.1,
        interval: Double = 0.08,
        animation: Animation = .contentSlide
    ) -> some View {
        modifier(StaggeredAppearModifier(
            index: index,
            style: style,
            baseDelay: baseDelay,
            staggerInterval: interval,
            animation: animation
        ))
    }
}

// MARK: - Transition Extensions

@available(iOS 17.0, macOS 14.0, *)
public extension AnyTransition {

    /// Slide up with fade -- great for appearing content.
    static var slideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        )
    }

    /// Scale with fade -- great for modals and popovers.
    static var scaleWithFade: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.85).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        )
    }

    /// Card-like entrance from below with slight scale.
    static var cardEntrance: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom)
                .combined(with: .scale(scale: 0.95))
                .combined(with: .opacity),
            removal: .opacity
        )
    }

    /// Slide from leading edge with fade.
    static var slideFromLeading: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .opacity
        )
    }

    /// Slide from trailing edge with fade.
    static var slideFromTrailing: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .opacity
        )
    }
}

// MARK: - Previews

@available(iOS 17.0, macOS 14.0, *)
#Preview("Appear Animations") {
    ScrollView {
        VStack(spacing: 16) {
            Text("Appear Animations")
                .font(.largeTitle).bold()
                .donkeyAppear(.fade)

            Text("Slide Up")
                .padding().frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .donkeyAppear(.slideUp(), delay: 0.2)

            Text("Scale In")
                .padding().frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .donkeyAppear(.scale(), delay: 0.4)

            Text("Pop!")
                .padding().frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .donkeyAppear(.pop(), delay: 0.6, animation: .bouncySpring)

            Text("Card Entrance")
                .padding().frame(maxWidth: .infinity)
                .background(Color.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .donkeyAppear(.cardEntrance, delay: 0.8)

            Text("Blur In")
                .padding().frame(maxWidth: .infinity)
                .background(Color.pink.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .donkeyAppear(.blur(), delay: 1.0)

            Divider().padding(.vertical)

            Text("Staggered List")
                .font(.headline)
                .donkeyAppear(.fade, delay: 1.2)

            ForEach(0..<5, id: \.self) { i in
                HStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text("Item \(i + 1)")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .donkeyStagger(index: i, style: .slideUp(), baseDelay: 1.4)
            }
        }
        .padding()
    }
}
