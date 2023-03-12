//
//  File.swift
//  
//
//  Created by Paco Sainz on 3/12/23.
//

import SwiftUI

struct PaywallPlanSectionView: View {
    let plans: [PaywallPlan]
    @Binding var selectedId: Int
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(plans) { plan in
                PaywallPlanView(title: plan.title, subText: plan.subText, price: plan.price, selected: plan.id == selectedId)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedId = plan.id
                    }
            }
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity)
    }
}



struct PaywallPlanView: View {
    let title: String
    var subText: String = ""
    let price: Double
    let selected: Bool
    
    @Environment(\.colorScheme) var colorScheme

    var localePrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let formattedTipAmount = formatter.string(from: price as NSNumber) {
            return "\(formattedTipAmount)"
        }
        
        return String(format:"$%.02f", price)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(subText)
                    .font(.caption)
            }
            Spacer()
            Text("\(localePrice)")
                .fontWeight(.semibold)
                .foregroundColor(selected ? .primary : .secondary.opacity(0.9))
                .font(.body)
                .padding(.vertical, 6)
                .frame(minWidth: 90)
                .bgOverlay(bgColor: .gray.opacity(0.2), radius: 15)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .selected(selected, radius: 12, fill: false, color: colorScheme == .dark ? .white : .black)
        .padding(.horizontal)
    }
}
