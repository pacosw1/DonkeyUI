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
    var buttonTyoe: ButtonType
    var action: () -> Void
    var padding: CGFloat

    var font: Font
    var fontWeight: Font.Weight
    var fullWidth: Bool
    @Environment(\.colorScheme) var colorScheme
    
    
    public init(label: String, color: Color = .accentColor, buttonTyoe: ButtonType = .filled, action: @escaping () -> Void = {}, padding: CGFloat = 1.5, font: Font = .body, fontWeight: Font.Weight = .heavy, fullWidth: Bool = false) {
        self.label = label
        self.color = color
        self.buttonTyoe = buttonTyoe
        self.action = action
        self.padding = padding
        self.font = font
        self.fontWeight = fontWeight
        self.fullWidth = fullWidth
    }
    
    
    var labelColor: Color {
        if buttonTyoe == .filled {
            return color.buttonText(darkMode: colorScheme == .dark)
        }
        return color
    }

    public var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .font(font)
                .fontWeight(fontWeight)
                .foregroundColor(labelColor)
                
        }
        .padding(.horizontal, padding * 10)
        .padding(.vertical, padding * 5)
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .bgOverlay(bgColor: buttonTyoe == .filled ? color: .clear, borderColor: buttonTyoe == .bordered ? color : .clear, borderWidth: 1.5)
        
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ButtonView(label: "Start", color: .pink, buttonTyoe: .filled, action: {}, fullWidth: false)
            ButtonView(label: "Start", color: .blue, buttonTyoe: .bordered, action: {}, fullWidth: false)
            ButtonView(label: "Start", color: .purple, buttonTyoe: .text, action: {}, fullWidth: false)

        }
    }
}
