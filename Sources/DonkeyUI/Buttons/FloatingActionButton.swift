//
//  FloatingActionButton.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/16/22.
//

import SwiftUI

public struct FloatingActionButton: ViewModifier {
    let systemIcon: String
    let action: () -> Void
    var hidden: Bool
    
    public init(systemIcon: String, action: @escaping () -> Void = {}, hidden: Bool = false) {
        self.systemIcon = systemIcon
        self.action = action
        self.hidden = hidden
    }
    
    @State private var animationScale = 1.0
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
            Button(action: {
                
                action()
                let impactHeavy = UIImpactFeedbackGenerator(style: .medium)
                impactHeavy.impactOccurred()
                
                // todo
            }) {
                IconView(image: systemIcon, color: .accentColor)
            }
//            .cornerRadius(50)
//            .foregroundColor(Color.blue)
//            .overlay(
//                Circle()
//                    .stroke(.blue)
//                    .scaleEffect(animationScale)
//                    .opacity(2 - animationScale)
////                    .animation(.easeInOut(duration: 1)
////                        .speed(0.8)
////                        .repeatForever(autoreverses: false),
////                               value: animationScale)
//            )
            
           
            .padding(.init(top: 0, leading: 0, bottom: 20, trailing:20))
            .onAppear {
                animationScale = 2.0
            }
            .hidden(hidden)
            
            
            .ignoresSafeArea(.keyboard, edges: .all)
            
        }
        .ignoresSafeArea(.keyboard, edges: .all)

        
    }
    
}

extension View {
    func floatingActionButton(systemIcon: String, action: @escaping () -> Void, hidden: Bool) -> some View {
        modifier(FloatingActionButton(systemIcon: systemIcon, action: action, hidden: hidden))
    }
}
