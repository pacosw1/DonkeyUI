//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 3/14/23.
//

import SwiftUI

public struct NewFeatureItem: Identifiable {
    public init(id: UUID = UUID(), icon: String, iconColor: Color, title: String, description: String) {
        self.id = id
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
    }
    
    public var id = UUID()
    var icon: String
    var iconColor: Color
    var title: String
    var description: String
}

public struct WhatsNewView: View {
    public init(title: String = "What's New", items: [NewFeatureItem] = [], action: @escaping () -> Void) {
        self.title = title
        self.items = items
        self.action = action
    }
    
    var title: String = "What's New"
    var items: [NewFeatureItem] = []
    var buttonLabel: String = "Continue"
    var action: () -> Void = {}
    public var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
            .padding(.bottom)
            .padding(.horizontal, 40)
            Divider()
            
            ScrollView(showsIndicators: false) {
                Grid(alignment: .leading, horizontalSpacing: 25, verticalSpacing: 25) {
                    ForEach(items) { item in
                        GridRow(alignment:.center) {
                            IconView(image: item.icon, color: item.iconColor, size: .veryLarge)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.title)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Text(item.description)
                                    .font(.callout)
                                    .foregroundStyle(.primary.opacity(0.8))
                            }
                        }
                    }
                }
                .padding(.vertical, 30)

            }
            .padding(.horizontal, 30)

            Divider()
            Spacer()
            ButtonView(label: buttonLabel, padding: 3.5, fullWidth: true, action: action)
                .padding(.vertical)
                .padding(.horizontal, 40)

        }
        
    }
}

struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView(items: [
            .init(icon: "heart.fill", iconColor: .pink, title: "Hello World", description: "We love you"),
            .init(icon: "star.fill", iconColor: .blue, title: "All new Rating System", description: "Get better ratings more easily"),
            .init(icon: "gift.fill", iconColor: .teal, title: "All New Rewards", description: "Get rewards whenever you use the app"),
            .init(icon: "bell.fill", iconColor: .red, title: "Reminders are back", description: "Better than ever before"),
            .init(icon: "book.fill", iconColor: .red, title: "All New Rewards", description: "Now easier to read"),
        ], action: {})
        .biometricLock()
    }
}
