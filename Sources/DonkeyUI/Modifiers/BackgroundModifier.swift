//
//  BackgroundModifier.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/22/22.
//

import SwiftUI

struct BackgroundModifier: ViewModifier {
    var backgroundColor: Color
    var dim: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            content
        }
        .brightness(dim ? -0.1 : 0.00001)
        .saturation(dim ? 0.1 : 1)

    }
}


extension View {
    func fullscreen(bgColor: Color = Color(uiColor: UIColor.secondarySystemBackground), dim: Bool = false) -> some View {
        modifier(BackgroundModifier(backgroundColor: bgColor, dim: dim))
        
    }
}



struct BackgroundModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello World")
                .foregroundColor(.blue)
        }
        .fullscreen(dim: true)
        .preferredColorScheme(.dark)
    }
}
