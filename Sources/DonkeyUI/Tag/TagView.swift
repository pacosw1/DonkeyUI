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
    let id: UUID
    
    var dull: Bool = false
    var delete: Bool = false
    var deleteAction: (UUID) -> Void
    var holdAction: () -> Void = {}
    var selected: Bool = false
    var verySmall: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    public init(id: UUID, title: String, color: Color, dull: Bool = false, delete: Bool = false, deleteAction: @escaping (UUID) -> Void = {_ in}, holdAction: @escaping () -> Void = {}, selected: Bool = false, verySmall: Bool = false) {
        self.title = title
        self.id = id
        self.color = color
        self.dull = dull
        self.delete = delete
        self.deleteAction = deleteAction
        self.holdAction = holdAction
        self.selected = selected
        self.verySmall = verySmall
    }

    var textColor: Color {
        #if canImport(UIKit)
        return Color(UIColor(color).darker(componentDelta: colorScheme == .light ? 0.3 : 0))
        #else
        return Color(NSColor(color).darker(componentDelta: colorScheme == .light ? 0.3 : 0))
        #endif
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
                    .foregroundStyle(dull ? .primary.opacity(0.6) : textColor)
                    .animation(.none, value: label)
            
            if delete {
                Button {
                    deleteAction(id)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(textColor)
                }
                .accessibilityLabel("Remove \(title)")
            }
                
        }

        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        
        #if canImport(UIKit)
        .bgOverlay(bgColor: selected ? color.opacity(0.2): dull ? .clear : Color(UIColor(color).lighter(componentDelta: 0.05)).opacity(0.3), radius: 15, borderColor: selected ? color :  dull ? .gray.opacity(0.2) : .clear, borderWidth:  selected ? 3 : dull ? 1 : 0)
        #else
        .bgOverlay(bgColor: selected ? color.opacity(0.2): dull ? .clear : Color(NSColor(color).lighter(componentDelta: 0.05)).opacity(0.3), radius: 15, borderColor: selected ? color :  dull ? .gray.opacity(0.2) : .clear, borderWidth:  selected ? 3 : dull ? 1 : 0)
        #endif
        .accessibilityLabel(title)

//            .card(color: Color(color.lighter(componentDelta: 0.0)).opacity(colorScheme == .light ? 0.2 : 0.2), padding: 0.5)

    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        
                HStack {
                    Spacer()
                    TagView(id: UUID(),title: "No way", color: .blue, delete: false, deleteAction: {_ in},verySmall: true)
                    TagView(id: UUID(), title: "No way", color: .pink, delete: false, deleteAction: {_ in},verySmall: false)
                    TagView(id: UUID(), title: "No way", color: .pink, delete: true, deleteAction: {_ in},verySmall: false)
                    Spacer()
            }
                

    }
}
