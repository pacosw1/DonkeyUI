//
//  File.swift
//  
//
//  Created by Paco Sainz on 3/12/23.
//

import SwiftUI

struct PaywallActionView: View {
    var selectePrice: String = "$2.99"
    var billingType: String = "Recurring Billing"
    var billingPeriod: String = "Month"
    var buyAction: () -> Void
    var isDisabled: Bool
    var isLoading: Bool
    var body: some View {
        VStack(alignment: .center) {
            
            
            ButtonView(
                label: "Start Free Trial",
                color: .blue,
                buttonTyoe: .filled, action: {
                    buyAction()
                },
                padding: 4,
                font: .subheadline,
                fontWeight: .heavy,
                fullWidth: true,
                disabled: true,
                isLoading: isLoading 
            )
            .padding(.horizontal)

            
            Text("1-week trial - Then \(selectePrice) / \(billingPeriod) - \(billingType) - Cancel Anytime")
            .multilineTextAlignment(.center)
                .font(.caption)
                .padding(.bottom, 0)
                .foregroundColor(.primary.opacity(0.7))
                .padding(.horizontal)
        }
    }
}

struct PaywallPolicyView: View {
    var restorePurchasesAction: () -> Void
    var body: some View {
        
        HStack(alignment: .center, spacing: 10) {
            Spacer()
            Text("Privacy")
                .font(.caption)
                .foregroundColor(.gray)
            
            ButtonView(label: "Restore Purchases", color: .accentColor.opacity(0.9), buttonTyoe: .text, action: restorePurchasesAction, font: .caption, fontWeight: .regular)
     
            Text("Terms")
                .font(.caption)
                .foregroundColor(.gray)

           
            Spacer()

        }
        .padding(.horizontal)
        .padding(.top)
    }
}
