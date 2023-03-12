//
//  CardModifier.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/17/22.
//

import SwiftUI

struct CardModifier: ViewModifier {
    let transparent: Bool
    let color: Color
    let padding: CGFloat
    func body(content: Content) -> some View {
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
    func card(transparent: Bool = false, color: Color = Color(UIColor.secondarySystemBackground), padding: CGFloat = 1) -> some View {
        modifier(CardModifier(transparent: transparent, color: color, padding: padding))
    }
}
