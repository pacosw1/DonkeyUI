import SwiftUI

// MARK: - CustomBlock

/// A wrapper for arbitrary SwiftUI content in an immersive onboarding section.
/// The content closure receives the current reveal progress (0...1).
public struct CustomBlock<Content: View>: ContentBlock, View {
    public let id: String
    public let timing: RevealTiming
    private let content: (Double) -> Content

    @Environment(\.immersiveRevealProgress) private var progress: Double

    public init(
        id: String = UUID().uuidString,
        timing: RevealTiming = .standard,
        @ViewBuilder content: @escaping (Double) -> Content
    ) {
        self.id = id
        self.timing = timing
        self.content = content
    }

    public var body: some View {
        content(progress)
            .modifier(RevealModifier(progress: progress, style: timing.style))
    }
}
