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
    var body: some View {
        VStack(alignment: .center) {
            
            
            ButtonView(
                label: "Start Free Trial",
                buttonTyoe: .filled, action: {
                    buyAction()
                },
                padding: 4,
                font: .subheadline,
                fontWeight: .heavy,
                fullWidth: true,
                disabled: isDisabled
            )
            .padding(.horizontal)

            
            Text("1-week trial - Then \(selectePrice) / \(billingPeriod) - \(billingType) - Cancel Anytime")
            .multilineTextAlignment(.center)
                .font(.caption)
                .padding(.bottom, 10)
                .foregroundColor(.black.opacity(0.7))
                .padding(.horizontal)
        }
    }
}

struct PaywallPolicyView: View {
    var body: some View {
        
        HStack(alignment: .center, spacing: 10) {
            Spacer()
            Text("Privacy")
                .font(.caption)
                .foregroundColor(.gray)
            Text("Restore Purchases")
                .font(.caption)
                .foregroundColor(.gray)
            Text("Terms")
                .font(.caption)
                .foregroundColor(.gray)

           
            Spacer()

        }
        .padding(.horizontal)
        .padding(.vertical)
    }
}
