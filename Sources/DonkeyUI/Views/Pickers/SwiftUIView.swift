//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 5/6/23.
//

import SwiftUI

enum PopoverOrigin {
case left,
    right,
    top,
    bottom
}

struct PopoverView<PopoverContent>: ViewModifier where PopoverContent: View {
    @State private var position: CGFloat = 0.0
    @State private var isShown: Bool = false
    let popoverContent: () -> PopoverContent
    @State private var popoverHeight: CGFloat = 0.0
    
    func body(content: Content) -> some View {
        GeometryReader { x in
            ZStack {
                content
                    .height(height: $position)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isShown = true
                    }
                
                popoverContent()
                    .card()
                    .height(height: $popoverHeight)
                    .opacity(isShown ? 1 : 0)
                    .animation(.interactiveSpring(), value: isShown)
                    .offset(y: popoverHeight - 5)
                
            }
        }
        
        .onTapGesture {
            isShown = false
        }
    }
        
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello")
            .popover {
                Text("This is a popover")
            }
            
    }
}


extension View {
    func popover<PopoverContent>(@ViewBuilder content: @escaping () -> PopoverContent) -> some View where PopoverContent: View {
        modifier(PopoverView(popoverContent: content))
    }
}
