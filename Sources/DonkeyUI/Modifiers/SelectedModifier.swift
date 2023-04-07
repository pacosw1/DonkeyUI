//
//  SelectedModifier.swift
//  BuildUp
//
//  Created by Paco Sainz on 11/13/22.
//

import SwiftUI

struct SelectedModifier: ViewModifier {
    public init(selected: Bool, radius: CGFloat, border: Bool, fill: Bool, color: Color) {
        self.selected = selected
        self.radius = radius
        self.border = border
        self.fill = fill
        self.color = color
    }
    
    
    let selected: Bool
    let radius: CGFloat
    let border: Bool
    let fill: Bool
    let color: Color
    public func body(content: Content) -> some View {
        content
            .bgOverlay(
                bgColor: selected && fill ? color.opacity(0.2) : .clear,
                radius: radius,
                borderColor: selected ? color : border ? .secondary.opacity(0.4) : .clear,
                borderWidth: selected ? 2 : border ? 1 : 0
            )

    }
}

extension View {
    public func selected(_ selected: Bool, radius: CGFloat = 5, border: Bool = true, fill: Bool = true, color: Color = .accentColor) -> some View {
        modifier(SelectedModifier(selected: selected, radius: radius, border: border, fill: fill, color: color))
    }
}





  
