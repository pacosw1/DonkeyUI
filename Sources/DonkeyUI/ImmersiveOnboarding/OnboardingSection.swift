import SwiftUI

// MARK: - OnboardingSection

/// A single section (page/chapter) in an immersive onboarding flow.
/// Contains multiple content blocks that reveal sequentially.
public struct OnboardingSection: Identifiable {
    public let id: String
    public let title: String?
    public let subtitle: String?
    public let backgroundColor: Color?
    public let accentColor: Color
    public let minimumDisplayTime: Duration
    public let continueButtonLabel: String
    public let celebrateOnComplete: Bool
    public let blocks: [any ContentBlock]

    public init(
        id: String = UUID().uuidString,
        title: String? = nil,
        subtitle: String? = nil,
        backgroundColor: Color? = nil,
        accentColor: Color = .accentColor,
        minimumDisplayTime: Duration = .seconds(5),
        continueButtonLabel: String = "Continue",
        celebrateOnComplete: Bool = false,
        @ImmersiveBlockBuilder blocks: () -> [any ContentBlock]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.minimumDisplayTime = minimumDisplayTime
        self.continueButtonLabel = continueButtonLabel
        self.celebrateOnComplete = celebrateOnComplete
        self.blocks = blocks()
    }
}

// MARK: - ImmersiveBlockBuilder

/// Result builder for declaratively composing content blocks within an onboarding section.
@resultBuilder
public struct ImmersiveBlockBuilder {

    public static func buildBlock(_ components: any ContentBlock...) -> [any ContentBlock] {
        components
    }

    public static func buildOptional(_ component: [any ContentBlock]?) -> [any ContentBlock] {
        component ?? []
    }

    public static func buildEither(first component: [any ContentBlock]) -> [any ContentBlock] {
        component
    }

    public static func buildEither(second component: [any ContentBlock]) -> [any ContentBlock] {
        component
    }

    public static func buildArray(_ components: [[any ContentBlock]]) -> [any ContentBlock] {
        components.flatMap { $0 }
    }
}
