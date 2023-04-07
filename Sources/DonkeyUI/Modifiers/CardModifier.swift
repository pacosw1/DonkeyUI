//
//  CardModifier.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/17/22.
//

import SwiftUI

public struct CardModifier: ViewModifier {
    public init(transparent: Bool, color: Color, padding: CGFloat) {
        self.transparent = transparent
        self.color = color
        self.padding = padding
    }
    
    let transparent: Bool
    let color: Color
    let padding: CGFloat
    public func body(content: Content) -> some View {
        if transparent {
            content
                .padding(.vertical, 14 * padding)
                .padding(.horizontal, 20 * padding)
                .bordered(color: color)
        } else {
            content
            .padding(.vertical, 14 * padding)
            .padding(.horizontal, 20 * padding)
            .bordered(color: color)
        }
    }
}

extension View {
    public func card(transparent: Bool = false, color: Color = Color(UIColor.secondarySystemBackground), padding: CGFloat = 1) -> some View {
        modifier(CardModifier(transparent: transparent, color: color, padding: padding))
    }
}
