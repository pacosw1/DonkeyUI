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
    text
}

public struct ButtonView: View {

    let label: String
    var color: Color
    var buttonType: ButtonType
    var action: () -> Void
    var padding: CGFloat
    

    var font: Font
    var fontWeight: Font.Weight
    var fullWidth: Bool
    var radius: CGFloat
    var disabled: Bool = false
    var isLoading: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    
    public init(label: String, color: Color = .accentColor, buttonTyoe: ButtonType = .filled, action: @escaping () -> Void = {}, padding: CGFloat = 1.5, font: Font = .body, fontWeight: Font.Weight = .heavy, fullWidth: Bool = false, disabled: Bool = false, radius: CGFloat = 12, isLoading: Bool = false) {
        self.label = label
        self.color = color
        self.buttonType = buttonTyoe
        self.action = action
        self.padding = padding
        self.font = font
        self.fontWeight = fontWeight
        self.fullWidth = fullWidth
        self.disabled = disabled
        self.radius = radius
        self.isLoading = isLoading
    }
    
    var labelColor: Color {
        
        if buttonType == .filled {
            return color.buttonText(darkMode: colorScheme == .dark)
        }
        if disabled {
            return color.opacity(0.3)
        }
        return color
    }

    public var body: some View {
        Button {
            action()
        } label: {
            if isLoading {
                SpinnerLoadingView()
            } else {
                Text(label)
                    .font(font)
                    .fontWeight(fontWeight)
                    .foregroundColor(labelColor)
            }
        }
        .padding(.horizontal, padding * 10)
        .padding(.vertical, padding * 5)
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .bgOverlay(bgColor: disabled ? color.opacity(0.19) : buttonType == .filled ? color: .clear, radius: radius, borderColor: buttonType == .bordered ? color : .clear, borderWidth: 1.5)
        .disabled(disabled)
        
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ButtonView(label: "Start", color: .pink, buttonTyoe: .filled, action: {}, fullWidth: false, disabled: true)
            ButtonView(label: "Start", color: .blue, buttonTyoe: .bordered, action: {}, fullWidth: false)
            ButtonView(label: "Start", color: .purple, buttonTyoe: .text, action: {}, fullWidth: false, disabled: true)

        }
    }
}
