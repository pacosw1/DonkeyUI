//
//  TagMenuView.swift
//  BuildUp
//
//  Created by Paco Sainz on 11/13/22.
//

import SwiftUI

public protocol TagItem: Identifiable {
    var internalId: UUID { get set }
    func getLabel() -> String
    func getColor() -> Color
    func getId() -> UUID
}


public struct ScrollTagSelector: View {
    public init(selected: Binding<(any TagItem)?>, tags: [any TagItem]) {
        self.tags = tags
        _selected = selected
    }
    

    @Binding var selected: (any TagItem)?
    let tags: [any TagItem]
    
    
    func isSelected(tag: any TagItem) -> Bool {
        if selected == nil {
            return false
        }
        
        return tag.getLabel() == selected?.getLabel()
    }
        
    public var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(tags, id: \.internalId) { tag in
                        TagView(title: tag.getLabel(), color: tag.getColor())
                            .onTapGesture {
                                withAnimation(.interactiveSpring()) {
                                    if isSelected(tag: tag) {
                                        let impactHeavy = UIImpactFeedbackGenerator(style: .soft)
                                        impactHeavy.impactOccurred()
                                        selected = nil
                                    } else {
                                        let impactHeavy = UIImpactFeedbackGenerator(style: .light)
                                        impactHeavy.impactOccurred()
                                        selected = tag
                                    }
                                }
                            }
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 2)
            }
            .scrollIndicators(.hidden)
        }
    }
}
