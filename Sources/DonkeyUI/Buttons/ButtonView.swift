//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 3/10/23.
//

import SwiftUI

public enum ButtonType {
case filled,
    bordered,
    text,
    card
}

public struct ButtonView: View {

    let label: String
    var color: Color
    var buttonType: ButtonType
    var action: () -> Void
    var padding: CGFloat
    var icon: String? = nil

    var font: Font
    var fontWeight: Font.Weight
    var fullWidth: Bool
    var radius: CGFloat
    var disabled: Bool = false
    var isLoading: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    public init(label: String, icon: String? = nil, color: Color = .accentColor, buttonType: ButtonType = .filled, padding: CGFloat = 1.5, font: Font = .body, fontWeight: Font.Weight = .heavy, fullWidth: Bool = false, disabled: Bool = false, radius: CGFloat = 12, isLoading: Bool = false, action: @escaping () -> Void = {}) {
        self.label = label
        self.color = color
        self.buttonType = buttonType
        self.action = action
        self.icon = icon
        self.padding = padding
        self.font = font
        self.fontWeight = fontWeight
        self.fullWidth = fullWidth
        self.disabled = disabled
        self.radius = radius
        self.isLoading = isLoading
    }
    
    var labelColor: Color {
        
        if buttonType == .filled && !disabled {
            return color.buttonText(darkMode: false)
        }
        
        if buttonType == .card && !disabled {
            return .accentColor
        }
        
        if disabled {
            return color.opacity(0.3)
        }
        return color
    }
    
    
    var isDisabled: Bool {
        if isLoading {
            return true
        }
        
        return disabled
    }
    
    var bgColor: Color {
        if isDisabled {
            if buttonType == .text {
                return .clear
            } else {
                return color.opacity(0.3)
            }
        } else {
            if buttonType == .filled {
                return color
            } else if buttonType == .card {
                return Color(UIColor.secondarySystemBackground)
                
            } else {
                return .clear
            }
        }
    }
    
    
    var borderColor: Color {
        if buttonType == .bordered {
            if !isDisabled {
                return color
            }
            return color.opacity(0.3)
        } else if buttonType == .card {
            return Color(UIColor(color).darker(componentDelta: 0.3))
        }
        
        return .clear
    }

    public var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                SpinnerLoadingView(color: color, disabled: isDisabled)
                    .opacity(isLoading ? 1 : 0)
                
                HStack(alignment: .center) {
                    if (icon != nil) {
                        Image(systemName: icon!)
                            .foregroundColor(labelColor)
                            .fontWeight(.semibold)
                    }
                    
                    Text(label)
                        .font(font)
                        .fontWeight(fontWeight)
                        .foregroundColor(labelColor)
                        .opacity(isLoading ? 0 : 1)
                }
            }
            .padding(.horizontal, padding * 10)
            .padding(.vertical, padding * 5)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .bgOverlay(bgColor: bgColor, radius: radius, borderColor: borderColor, borderWidth: 1.5)
            .contentShape(Rectangle())

            
        }
        
        .disabled(isDisabled)
        
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            
//
//            ButtonView(label: "Start", color: .pink, buttonTyoe: .filled, action: {}, padding: 3, fullWidth: false, disabled: true)
            ButtonView(label: "Start", icon: "faceid", color: .blue, buttonType: .filled, fullWidth: false, disabled: false, action: {})
            ButtonView(label: "Start", color: .blue, buttonType: .filled, fullWidth: false, disabled: false, isLoading: true, action: {})
//            ButtonView(label: "Start", color: .purple, buttonTyoe: .filled, action: {}, fullWidth: false, disabled: true, isLoading: false)


        }
//        .preferredColorScheme(.dark)
    }
}
