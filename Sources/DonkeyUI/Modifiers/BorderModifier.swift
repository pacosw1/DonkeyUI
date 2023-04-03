//
//  BorderModifier.swift
//  Divergent
//
//  Created by paco on 26/11/22.
//
import SwiftUI

public struct BorderModifier: ViewModifier {
    public init(color: Color) {
        self.color = color
    }
    
    let color: Color
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous).fill(
                    color)
                
            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke( Color(UIColor.tertiaryLabel),
//                             lineWidth: 1)
//            )

    }
}

extension View {
    func bordered(color: Color = Color(uiColor: UIColor.secondarySystemBackground)) -> some View {
        modifier(BorderModifier(color: color))
    }
}
    
