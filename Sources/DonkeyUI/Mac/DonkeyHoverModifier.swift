//
//  DonkeyHoverModifier.swift
//  DonkeyUI
//
//  Animated hover effect modifier for macOS and iOS pointer interactions.

#if !os(watchOS)
import SwiftUI

public struct DonkeyHoverModifier: ViewModifier {
    let scale: CGFloat
    let opacity: CGFloat
    let highlightColor: Color?

    @State private var isHovered = false

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? scale : 1.0)
            .opacity(isHovered ? opacity : 1.0)
            .background(
                Group {
                    if let highlightColor, isHovered {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(highlightColor)
                    }
                }
            )
            .onHover { isHovered = $0 }
            .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
}

public extension View {
    /// Adds an animated hover effect with optional scale, opacity, and background highlight.
    func donkeyHover(
        scale: CGFloat = 1.02,
        opacity: CGFloat = 0.9,
        highlightColor: Color? = nil
    ) -> some View {
        modifier(DonkeyHoverModifier(scale: scale, opacity: opacity, highlightColor: highlightColor))
    }
}

#Preview {
    VStack(spacing: 16) {
        Text("Hover me")
            .padding()
            .background(Color.blue.opacity(0.2))
            .donkeyHover()

        Text("Hover with highlight")
            .padding()
            .donkeyHover(highlightColor: Color.blue.opacity(0.1))
    }
    .padding()
}
#endif
