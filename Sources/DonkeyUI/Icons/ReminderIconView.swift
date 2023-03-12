//
//  ReminderIconView.swift
//  BuildUp
//
//  Created by Paco Sainz on 11/6/22.
//

import SwiftUI

public struct ReminderIconView: View {
    let timeLabel: String
    let optionLabel: String
    let selected: Bool
    var small: Bool = false
    
    public var body: some View {
        VStack(spacing: 0) {
            Text("\(timeLabel)")
                .fontWeight(.heavy)
                .font(.title3)
                
            Text(optionLabel)
                .font(.caption)
                .fontWeight(.regular)
                .foregroundColor(.secondary)
            
            
                
        }
        .frame(maxWidth: .infinity)
//        .frame(width: 30, height: 30)
//        .padding(.horizontal, 10)
        .padding(.vertical, small ? 3: 10)
        .bgOverlay(bgColor: Color(UIColor.tertiarySystemBackground), borderColor: selected ? .accentColor : .gray, borderWidth: selected ? 2 : 1)
        .overlay {
            
            Color.accentColor.opacity(0.1)
                .hidden(!selected)
        }
    }
}

struct ReminderIconView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ReminderIconView(timeLabel: "5", optionLabel: "Min", selected: true)
            ReminderIconView(timeLabel: "10", optionLabel: "Min", selected: false)
            ReminderIconView(timeLabel: "15", optionLabel: "Min", selected: false)
            ReminderIconView(timeLabel: "30", optionLabel: "Min", selected: false)
            ReminderIconView(timeLabel: "1", optionLabel: "Hour", selected: false)

        }
        .preferredColorScheme(.dark)
    }
}
