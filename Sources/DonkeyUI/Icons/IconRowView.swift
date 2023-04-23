//
//  IconRowView.swift
//  Divergent
//
//  Created by paco on 29/11/22.
//

import SwiftUI

public struct IconRowView: View {
    let icon: String
    let label: String
    let color: Color
    let badgeCount: Int
    var badgeColor: Color
    var inverted: Bool
    
    public init(icon: String, label: String, color: Color, badgeCount: Int, badgeColor: SwiftUI.Color = Color.pink, inverted: Bool = true) {
        self.icon = icon
        self.label = label
        self.color = color
        self.badgeCount = badgeCount
        self.badgeColor = badgeColor
        self.inverted = inverted
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            IconView(image: icon, color: color, size: .verySmall, inverted: inverted)
//                                        .padding(5)
//                                        .bgOverlay(bgColor: view.color)
            Text(label)
                .foregroundColor(.primary)
                .fontWeight(.semibold)
            Spacer()
            BadgeLabelView(count: badgeCount, color: badgeColor)
                .hidden(badgeCount == 0)
            
        }
    }
}

struct IconRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            IconRowView(icon: "heart.fill", label: "Nice", color: .green, badgeCount: 0)
            IconRowView(icon: "star.fill", label: "Logbook", color: .green, badgeCount: 0)
            IconRowView(icon: "calendar", label: "Logbook", color: .green, badgeCount: 0)

        }
        .padding()
    }
}
