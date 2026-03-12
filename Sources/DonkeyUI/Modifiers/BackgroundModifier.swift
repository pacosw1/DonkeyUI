//
//  BackgroundModifier.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/22/22.
//

import SwiftUI

public struct BackgroundModifier: ViewModifier {
    public init(backgroundColor: Color, dim: Bool) {
        self.backgroundColor = backgroundColor
        self.dim = dim
    }
    
    var backgroundColor: Color
    var dim: Bool
    
    public func body(content: Content) -> some View {
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
    public func fullscreen(bgColor: Color = DonkeyUIDefaults.secondaryBackground, dim: Bool = false) -> some View {
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
