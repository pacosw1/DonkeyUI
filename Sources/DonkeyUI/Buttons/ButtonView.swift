//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 3/10/23.
//

import SwiftUI

enum ButtonType {
case filled,
    bordered,
    text
}

public struct ButtonView: View {
    let label: String
    var color: Color = .accentColor
    var buttonTyoe: ButtonType = .bordered
    var action: () -> Void
    var padding: CGFloat = 1.5

    var font: Font = .body
    var fontWeight: Font.Weight = .heavy
    var fullWidth: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    
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
        ButtonView(label: "Start", color: .pink, buttonTyoe: .filled, action: {}, fullWidth: true)
    }
}
