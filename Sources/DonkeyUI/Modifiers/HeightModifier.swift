//
//  File.swift
//  
//
//  Created by Paco Sainz on 5/6/23.
//

import Foundation

import SwiftUI

struct GetHeightModifier: ViewModifier {
    @Binding var height: CGFloat

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo -> Color in
                height = geo.size.height
                return Color.clear
            }
        )
    }
}


extension View {
    func height(height: Binding<CGFloat>) -> some View {
        modifier(GetHeightModifier(height: height))
    }
}
