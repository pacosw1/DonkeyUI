//
//  RoundedOverlayModifier.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/30/22.
//

import SwiftUI

public struct OverlayModifier: ViewModifier {
    var backgroundColor: Color
    var radius: CGFloat
    var borderColor: Color
    var borderWidth: CGFloat = 1
    
//    private var textColor: Color {
//        return DarkColor(color: backgroundColor) ? .white: .black
//    }
    
    public func body(content: Content) -> some View {
            content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(backgroundColor)

            )
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(borderColor,
                            lineWidth: borderWidth)
            )
    }
}


extension View {
    public func bgOverlay(bgColor: Color, radius: CGFloat = 5.0, borderColor: Color = .clear, borderWidth: CGFloat = 1.0) -> some View {
        modifier(OverlayModifier(backgroundColor: bgColor, radius: radius, borderColor: borderColor, borderWidth: borderWidth))
    }
}



struct OverlayModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button("Hello") {
            }
            .padding()
            .bgOverlay(bgColor: .pink)
            
        }
        
    }
}
