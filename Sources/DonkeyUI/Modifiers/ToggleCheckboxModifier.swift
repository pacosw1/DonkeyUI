//
//  ToggleCheckbox.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/15/22.
//
import SwiftUI




public struct CheckboxViewModifier: ViewModifier {
    @Binding var isOn: Bool
    var color: Color
    var disabled: Bool
    var size: ButtonSize
    var action: () -> Void
    
    @State var opacity = 1.0
    @State var scale = 1.0
    
    @State private var isPressed = false

    
    public func body(content: Content) -> some View {
        
        HStack(alignment: .center) {
            ZStack(alignment: .topLeading) {
                
                
                content
                    .offset(x: 35)
                
                Button(action: {
                    isOn.toggle()
                    
                    withAnimation {
                        action()
                    }
                    
                    #if canImport(UIKit)
                    let impactHeavy = UIImpactFeedbackGenerator(style: .medium)
                    impactHeavy.impactOccurred()
                    #endif
                    
                }) {
                    CheckButtonView(active: isOn, size: size)
                        .animation(nil, value: isOn)
                        .opacity(disabled ? 0.2 : 1)
                        .padding(.leading, 5)
                        .padding(.trailing, 3)
                    
                    //                    .bgOverlay(bgColor: .blue)
                }
                .disabled(disabled)
                .buttonStyle(.borderless)
                .contentShape(Rectangle())
                
            }
        }
        
     
        
//        .card()
        
        
        
    }
}
public extension View {
    func checkbox(isOn: Binding<Bool>, color: Color = .accentColor, disabled: Bool, size: ButtonSize = .medium, action: @escaping () -> Void) -> some View {
        modifier(CheckboxViewModifier(isOn: isOn, color: color, disabled: disabled, size: size, action: action))
    }
}
