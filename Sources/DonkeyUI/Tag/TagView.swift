//
//  TagView.swift
//  BuildUp
//
//  Created by Paco Sainz on 11/13/22.
//

import SwiftUI

public struct TagView: View {
    let title: String
    let color: Color
    
    var dull: Bool = false
    var delete: Bool = false
    var deleteAction: (UUID) -> Void
    var holdAction: () -> Void = {}
    var selected: Bool = false
    var verySmall: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    init(title: String, color: Color, dull: Bool = false, delete: Bool = false, deleteAction: @escaping (UUID) -> Void = {_ in}, holdAction: @escaping () -> Void = {}, selected: Bool = false, verySmall: Bool = false) {
        self.title = title
        self.color = color
        self.dull = dull
        self.delete = delete
        self.deleteAction = deleteAction
        self.holdAction = holdAction
        self.selected = selected
        self.verySmall = verySmall
    }

    var textColor: Color {
        return Color(UIColor(color).darker(componentDelta: colorScheme == .light ? 0.3 : 0))
    }
    
    var verticalPadding: CGFloat {
        if verySmall {
            return 2
        }
        return 5
    }
    
    var horizontalPadding: CGFloat {
        if verySmall {
            return 5
        }
        return 10
    }
    
    var titleFont: Font {
        if verySmall {
            return .caption2
        }
        return .body
    }
    
    var label: String {
        if verySmall {
            if title.count > 10 {
                return title.prefix(10) + "..."
            }
        }
        
        if title.count > 18 {
            return title.prefix(18) + "..."
        }
        
        return title
    }
    
    
    public var body: some View {
        
        HStack(spacing: 8) {
            Text(label)
                    .fontWeight(.semibold)
                    .font(titleFont)
                    .foregroundColor(dull ? .primary.opacity(0.6) : textColor)
                    .animation(.none, value: label)
                
        }

        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        
        .bgOverlay(bgColor: selected ? color.opacity(0.2): dull ? .clear : Color(UIColor(color).lighter(componentDelta: 0.05)).opacity(0.3), radius: 15, borderColor: selected ? color :  dull ? .gray.opacity(0.2) : .clear, borderWidth:  selected ? 3 : dull ? 1 : 0)
                    
//            .card(color: Color(color.lighter(componentDelta: 0.0)).opacity(colorScheme == .light ? 0.2 : 0.2), padding: 0.5)
        
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        
            ScrollView(.horizontal) {
                HStack {
//                    TagView(label: "Health", color: .pink, dull: true)
//                    TagView(tagItem: TestTag(title: "hello", hue: .pink), delete: false, deleteAction: {_ in})
                    TagView(title: "No way", color: .blue, delete: false, deleteAction: {_ in},verySmall: true)
//                TagView(label: "Home", color: .pink)




            }
                .frame(maxWidth: .infinity, minHeight: 50)
                
        }
            .frame(maxWidth: .infinity, minHeight: 50)

    }
}
