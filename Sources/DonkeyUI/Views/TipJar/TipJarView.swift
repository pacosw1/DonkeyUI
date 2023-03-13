//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 3/10/23.
//

import SwiftUI

public struct TipJarView: View {
    public init(titleIcon: String, options: [TipJarOption], titleLabel: String, titleDescription: String, confirmPurchaseLabel: String, optionalDisclaimer: String? = nil, purchaseAction: @escaping () -> Void, closeAction: @escaping () -> Void, selected: UUID = UUID()) {
        self.titleIcon = titleIcon
        self.options = options
        self.titleLabel = titleLabel
        self.titleDescription = titleDescription
        self.confirmPurchaseLabel = confirmPurchaseLabel
        self.optionalDisclaimer = optionalDisclaimer
        self.purchaseAction = purchaseAction
        self.closeAction = closeAction
        self.selected = selected
    }
    
    // TODO add options, we also need an api to make diff implementations under the hood.
    let titleIcon: String
    let options: [TipJarOption]
    let titleLabel: String
    let titleDescription: String
    let confirmPurchaseLabel: String
    let optionalDisclaimer: String?
    
    var purchaseAction: () -> Void
    var closeAction: () -> Void
    
    @State var selected: UUID = UUID()
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                CloseButton(action: closeAction)
                .padding(.trailing)
            }
            .padding(.vertical)
            .padding(.bottom)
//            Spacer()
            HStack(alignment: .center, spacing: 15) {
                IconView(image: titleIcon, color: .pink, size: .huge)
                Text(titleLabel)
                    .fontWeight(.heavy)
                    .font(.title)
                    .padding(.bottom, 5)
            }
            Text(titleDescription)
                .font(.callout)
                .padding(.bottom)
                .padding(.bottom)

            ForEach(options) { option in
                TipJarOptionView(label: option.label, price: option.price, selected: option.id == selected)
                    .onTapGesture {
                        selected = option.id
                    }
            }
            Spacer()
            VStack(alignment: .center) {
                ButtonView(label: confirmPurchaseLabel, buttonTyoe: .filled, action: purchaseAction, padding: 3, font: .title3, fullWidth: true)
                Text(optionalDisclaimer ?? "")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        
        .padding(.horizontal)
        .task {
            if !options.isEmpty {
                selected = options.first!.id
            }
        }
    }
    
}

struct TipJarOptionView: View {
    let label: String
    let price: Float
    let selected: Bool
     var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .fontWeight(.heavy)
                Spacer()
            Text(String(format: "$%.2f", price))
                .fontWeight(.light)
                .font(.title3)
        }
        .padding()
        .contentShape(Rectangle())
        .selected(selected, radius: 5, border: true, color: .blue)
    }
}

struct TipJarView_Previews: PreviewProvider {
    static var previews: some View {
        TipJarView(titleIcon: "heart.fill", options: [
            .init(label: "☕️ Coffee", price: 2.99),
            .init(label: "🥨 Snack", price: 4.99),
            .init(label: "🍕 Pizza", price: 9.99),
            .init(label: "🍽️ Nice Dinner", price: 19.99)
        ],
        titleLabel: "Help me keep this app alive!",
        titleDescription: "This app is free thanks to tips. If you enjoyed using this app and want to help me pay the bills, feel free to add a tip. It's completelty optional, but it keeps this app alive!",
        confirmPurchaseLabel: "Confirm Tip",
        optionalDisclaimer: "Thank you so much!. This action is not refundable",
        purchaseAction: {},
        closeAction: {})
        
    }
}
