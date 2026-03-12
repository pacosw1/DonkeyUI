//
//  BorderModifier.swift
//  Divergent
//
//  Created by paco on 26/11/22.
//
import SwiftUI

public struct BorderModifier: ViewModifier {
    public init(color: Color, radius: BorderRadius) {
        self.color = color
        self.radius = radius
    }
    
    let radius: BorderRadius
    let color: Color
    
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius.rawValue, style: .continuous).fill(
                    color)
                
            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke( Color(UIColor.tertiaryLabel),
//                             lineWidth: 1)
//            )

    }
}

public extension View {
    func bordered(color: Color = DonkeyUIDefaults.secondaryBackground, radius: BorderRadius = .card) -> some View {
        modifier(BorderModifier(color: color, radius: radius))
    }
}
