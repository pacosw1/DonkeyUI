//
//  File.swift
//  
//
//  Created by Paco Sainz on 3/12/23.
//

import SwiftUI

struct FeatureView: View {
    let title: String
    let image: String
    let text: String
    let color: Color
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            IconView(image: image, color: color, size: .large)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(text)
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(.primary.opacity(0.7))
            }
        }
    }
}


struct RemindersPromotionView: View {
    var body: some View {
        VStack(alignment:. leading, spacing: 20) {
            FeatureView(title: "Hardcore Reminders", image: "bell.badge.fill", text: "Never forget about deadlines again ...ever!", color: .pink)
            
            HStack {
                ReminderIconView(timeLabel: "5", optionLabel: "Min", selected: true)
                ReminderIconView(timeLabel: "10", optionLabel: "Min", selected: true)
                ReminderIconView(timeLabel: "15", optionLabel: "Min", selected: true)
                ReminderIconView(timeLabel: "30", optionLabel: "Min", selected: false)
                ReminderIconView(timeLabel: "60", optionLabel: "Min", selected: true)
                ReminderIconView(timeLabel: "1", optionLabel: "Day", selected: false)
            }
        }
    }
}

struct ListsPromotionView: View {
    var body: some View {
        VStack {
            FeatureView(title: "Unlimited lists", image: "list.bullet.clipboard.fill", text: "Keep track of all your projects in one place", color: .purple)
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 10) {
                    CircularProgressView(progress: 0.9, size: 8)
                    Text("WFH Setup")
                        .fontWeight(.semibold)
                }
                .card()

                HStack(spacing: 10) {
                    CircularProgressView(color: .pink, progress: 0.8, size: 8)
                    Text("Kitchen Renovation")
                        .fontWeight(.semibold)
                }
                .card()
            }
        }
    }
}
//
struct TagsPromotionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            FeatureView(title: "Unlimited Tags", image: "tag.fill", text: "Tags help you organize your tasks all the way", color: .orange)
            VStack(alignment: .leading) {
                HStack {
                    TagView(title: "Work", color: .blue, deleteAction: {_ in})
                    TagView(title: "Gym", color: .pink, deleteAction: {_ in})
                    TagView(title: "Health", color: .green, deleteAction: {_ in})
                }
                HStack {
                    TagView(title: "School", color: .purple, deleteAction: {_ in})
                    TagView(title: "Vactations", color: .indigo, deleteAction: {_ in})
                    TagView(title: "Hobby", color: .teal, deleteAction: {_ in})
                }
            }
        }
    }
}
//
struct IndieDevPromotion: View {
    var body: some View {
        VStack {
            FeatureView(title: "Support an Indie Developer", image: "gift.fill", text: "It's just me behind the app", color: .mint)
        }
    }
}
//
//
//
//
//
//
//
