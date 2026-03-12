//
//  CardModifier.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/17/22.
//

import SwiftUI

public enum BorderRadius: CGFloat {
case slightly = 5,
    card = 12,
    bottomMenu = 18,
    round = 22
}

public struct CardModifier: ViewModifier {
    public init(radius: BorderRadius, transparent: Bool, color: Color, padding: CGFloat) {
        self.transparent = transparent
        self.color = color
        self.padding = padding
        self.radius = radius
    }
    
    let transparent: Bool
    let radius: BorderRadius
    let color: Color
    let padding: CGFloat
    public func body(content: Content) -> some View {
        if transparent {
            content
                .padding(.vertical, 14 * padding)
                .padding(.horizontal, 20 * padding)
                .bordered(color: .clear, radius: radius)
        } else {
            content
            .padding(.vertical, 14 * padding)
            .padding(.horizontal, 20 * padding)
            .bordered(color: color, radius: radius)
        }
    }
}

extension View {
    public func card(transparent: Bool = false, color: Color = DonkeyUIDefaults.secondaryBackground, padding: CGFloat = 1, radius: BorderRadius = .card) -> some View {
        modifier(CardModifier(radius: radius, transparent: transparent, color: color, padding: padding))
    }
}
