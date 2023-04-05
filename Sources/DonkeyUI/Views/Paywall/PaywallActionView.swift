//
//  File.swift
//  
//
//  Created by Paco Sainz on 3/12/23.
//

import SwiftUI

struct PaywallActionView: View {
    var selectePrice: String
    var billingType: String
    var billingPeriod: String
    var buyAction: () -> Void
    var isDisabled: Bool
    var isLoading: Bool
    var body: some View {
        VStack(alignment: .center) {
            
            
            ButtonView(
                label: billingType == "Recurring Billing" ? "Start Free Trial" : "Continue",
                color: .blue,
                buttonTyoe: .filled, action: {
                    buyAction()
                },
                padding: 4,
                font: .subheadline,
                fontWeight: .heavy,
                fullWidth: true,
                disabled: isDisabled,
                isLoading: false
            )
            .padding(.horizontal)

            
            Text("\(billingType == "Recurring Billing" ? "1-week trial - Then" : "Instant Purchase -") \(selectePrice) / \(billingPeriod) - \(billingType) - Cancel Anytime")
                .multilineTextAlignment(.center)
                .font(.caption)
                .padding(.bottom, 0)
                .padding(.top, 0)
                .foregroundColor(.primary.opacity(0.7))
                .padding(.horizontal)
//                .frame(minHeight: 30)
        }
    }
}

struct PaywallPolicyView: View {
    var restorePurchasesAction: () -> Void
    var privacyURL: String
    var termsOfServiceURL: String
    var body: some View {
        
        HStack(alignment: .center, spacing: 20) {
            Spacer()
            Link(destination: URL(string: privacyURL)!) {
                Text("Privacy")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Button ("Restore Purchases") { restorePurchasesAction() }
     
            Link(destination: URL(string: termsOfServiceURL)!) {
                Text("Terms")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

           
            Spacer()

        }
        .padding(.horizontal)
        .padding(.top)
    }
}
