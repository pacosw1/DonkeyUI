//
//  ColorPickerView.swift
//  Divergent
//
//  Created by paco on 02/12/22.
//

import SwiftUI
import WrappingHStack

public struct ColorPickerItem: View {

    let color: Color
    let selected: Bool
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(!selected ? .clear : Color(UIColor.tertiaryLabel).opacity(0.8), lineWidth: 4)
                .frame(height: 50)
            Circle()
                .fill(color)
                .frame(height: 40)
                .overlay {
                }
        }
    }
}

public struct ColorPickerView: View {
    public init(colors: [Color] = [
        .pink,
        .orange,
        .blue,
        .indigo,
        .green,
        .mint,
        .purple,
        .cyan,
        .brown,
        .black,
        .gray,
        

    ], selected: Binding<Color>, verticalSpacing: CGFloat = 10, horizontalSpacing: CGFloat = 40) {
        self.colors = colors
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        _selected = selected
    }
    
    var colors: [Color]
    let verticalSpacing: CGFloat
    let horizontalSpacing: CGFloat
    @Binding var selected: Color
    
    public var body: some View {
        WrappingHStack(alignment: .leading, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing) {
           ForEach(colors, id: \.self) { color in
               ColorPickerItem(color: color, selected: color.toHex() == selected.toHex())
                   .onTapGesture {
                       selected = color
                   }
                   .animation(.none, value: selected)
           }
       }
        .padding()
        .bordered()
    }
}

struct ColorPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerView(colors: [
            .blue,
            .green,
            .cyan,
            .purple
        ], selected: .constant(.blue))
        .padding()
    }
}
