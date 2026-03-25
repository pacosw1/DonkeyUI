import SwiftUI

#if os(iOS)

// MARK: - DonkeyPointerEffect

/// Pointer hover effect styles for iPadOS cursor interactions.
public enum DonkeyPointerEffect {
    case lift
    case highlight
    case automatic
}

// MARK: - Modifier

private struct DonkeyPointerStyleModifier: ViewModifier {
    let effect: DonkeyPointerEffect

    func body(content: Content) -> some View {
        switch effect {
        case .lift:
            content.hoverEffect(.lift)
        case .highlight:
            content.hoverEffect(.highlight)
        case .automatic:
            content.hoverEffect(.automatic)
        }
    }
}

// MARK: - View Extension

public extension View {
    /// Applies an iPadOS pointer hover effect.
    func donkeyPointerStyle(_ effect: DonkeyPointerEffect = .automatic) -> some View {
        modifier(DonkeyPointerStyleModifier(effect: effect))
    }
}

#endif
