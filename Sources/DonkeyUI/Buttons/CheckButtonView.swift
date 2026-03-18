//
//  CheckButtonView.swift
//  Divergent
//
//  Created by Paco Sainz on 1/3/23.
//

import SwiftUI

public enum ButtonSize: CGFloat {
    case tiny = 10,
         verySmall = 15,
         small = 20,
         medium = 25,
         large = 30
}

public struct CheckButtonView: View {
    let active: Bool

    let size: ButtonSize
    var color: Color
    
    var radius: CGFloat {
        return percent * 10
    }
    
    var percent: CGFloat {
        return size.rawValue / 30.0
    }
    
    var checkSize: CGFloat {
        switch size {
        case .tiny:
            return 5
        case .verySmall:
            return 7
        case .small:
            return 10
        case .medium:
            return 12
        case .large:
            return 15
            
        }
    }
    
    public init(active: Bool, size: ButtonSize = .medium, color: Color = .accentColor) {
        self.active = active
        self.size = size
        self.color = color
    }
    
    var fillColor: Color {
        #if canImport(UIKit)
        return Color(UIColor(color).lighter(componentDelta: 0.05))
        #else
        return Color(NSColor(color).lighter(componentDelta: 0.05))
        #endif
    }

    public var body: some View {

        RoundedRectangle(cornerRadius: radius, style: .continuous).fill(active ? fillColor : .clear)
            .frame(width: size.rawValue, height: size.rawValue)
            .overlay (
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .fontWeight(.heavy)
                    .font(.system(size: checkSize))
            )
            .opacity(active ? 1 : 0)
            .animation(.interactiveSpring(), value: active)

        .overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(fillColor,
                        lineWidth: 1.5)
        )
        .padding(.trailing, 22)
//        .bgOverlay(bgColor: .red.opacity(0.2))
        .contentShape(Rectangle())
        .animation(.interactiveSpring(), value: active)
        .accessibilityLabel(active ? "Checked" : "Unchecked")
        .accessibilityAddTraits(.isButton)

    }
}

/*
 .bgOverlay(bgColor: selected ? tagItem.getColor().opacity(0.2): dull ? .clear : Color(UIColor(tagItem.getColor()).lighter(componentDelta: 0.05)).opacity(0.3), radius: 15, borderColor: selected ? tagItem.getColor() :  dull ? .gray.opacity(0.2) : .clear, borderWidth:  selected ? 3 : dull ? 1 : 0)
 */
struct CheckButtonView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(alignment: .lastTextBaseline) {
            CheckButtonView(active: (false), size: .tiny)
            CheckButtonView(active: (true), size: .verySmall)
            CheckButtonView(active: (true), size: .small)
            CheckButtonView(active: (true), size: .medium)
            CheckButtonView(active: (true), size: .large)
        }
    }
}
