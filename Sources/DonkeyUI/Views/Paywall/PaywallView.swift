//
//  PopupView.swift
//  Divergent
//
//  Created by Paco Sainz on 12/31/22.
//

import SwiftUI

struct PaywallPlan: Identifiable {
    let id: Int
    let title: String
    let subText: String
    let price: Double
    let billingType: String
    let billingPeriod: String
}

struct PaywallView: View {
    var plans: [PaywallPlan] = []
    var views: [IdentifiableView] = []
    var closeAction: () -> Void = {}
    
    @State var selectedPlan: Int = 0
    @State var lastUpdate: Int64 = 0
    
    var activePlan: PaywallPlan {
        return plans[selectedPlan]
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            PaywallHeaderView(closeAction: closeAction)
            Divider()
            PaywallFeatureSectionView(views: views)
            PaywallPlanSectionView(plans: plans, selectedId: $selectedPlan)
            PaywallActionView(selectePrice: activePlan.price, billingType: activePlan.billingType, billingPeriod: activePlan.billingPeriod)
            Spacer()
            PaywallPolicyView()
        }
    }
}


struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(plans: [
            .init(id: 0, title: "Monthly", subText: "Our most affordable plan", price: 2.99, billingType: "Recurring Billing", billingPeriod: "Month"),
            .init(id: 1, title: "Yearly", subText: "Save 30%", price: 24.99, billingType: "Recurring Billing", billingPeriod: "Year"),
            .init(id: 2, title: "Lifetime Deal", subText: "One-time payment", price: 49.99, billingType: "One Time Payment", billingPeriod: "Once")
        ], views: [
            .init(view: AnyView(RemindersPromotionView()), maxWidth: 300),
            .init(view: AnyView(ListsPromotionView()), maxWidth: 300),
            .init(view: AnyView(TagsPromotionView())),
            .init(view: AnyView(IndieDevPromotion()), maxWidth: 400)
        ])
    }
}
