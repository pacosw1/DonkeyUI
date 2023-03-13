//
//  PopupView.swift
//  Divergent
//
//  Created by Paco Sainz on 12/31/22.
//

import SwiftUI
import RevenueCat

public struct PaywallPlan: Identifiable {
    
    public init(id: String, title: String, subText: String, price: String, billingType: String, billingPeriod: String, index: Int) {
        self.id = id
        self.index = index
        self.title = title
        self.subText = subText
        self.price = price
        self.billingType = billingType
        self.billingPeriod = billingPeriod
//        self.purchaseHandler = PurchaseHandler()
    }
    
    public let id: String
    let title: String
    let subText: String
    let price: String
    let billingType: String
    let billingPeriod: String
    let index: Int
}

public struct PaywallView: View {
    var views: [IdentifiableView] = []
    var closeAction: () -> Void = {}
    @ObservedObject var purchaseHandler: PurchaseHandler
    @State var loading: Bool = true
    
    @State var selectedPlan: PaywallPlan?
    @State var progress: CGFloat = 0.3
  
    public init(plans: [PaywallPlan] = [], views: [IdentifiableView] = [], closeAction: @escaping () -> Void = {}, selectedPlan: PaywallPlan?) {
        self.views = views
        self.closeAction = closeAction
        self.selectedPlan = nil
        self.purchaseHandler = PurchaseHandler()
    }
    
    public var body: some View {
            
            VStack {
                PaywallHeaderView(closeAction: closeAction)
                Divider()
                PaywallFeatureSectionView(views: views)
                PaywallPlanSectionView(plans: purchaseHandler.plans, selectedPlan: $selectedPlan)
                PaywallActionView(selectePrice: selectedPlan?.price ?? "9", billingType: selectedPlan?.billingType ?? "", billingPeriod: selectedPlan?.billingPeriod ?? "")
                Spacer()
                PaywallPolicyView()
            }
            .overlay {
                ZStack {
                    Color.white
                        .ignoresSafeArea()
                    VStack {
                        HStack {
                            Spacer()
                            CloseButton(action: {})
                        }
                        .padding(.trailing)
                        .padding(.top)
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressBarView(fullWidth: true, progress: $progress)
                                .padding(.horizontal, 50)
                                .padding(.bottom, 50)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .opacity(loading ? 1 : 0)
                .animation(.easeOut, value: loading)
            }
           
            
        .task {
            Purchases.configure(withAPIKey: "")
            withAnimation {
                progress = 0.95
            }
            let worked = await self.purchaseHandler.fetchProducts(revenueCatApi: Purchases.shared)
            if worked && !purchaseHandler.plans.isEmpty  {
                selectedPlan = purchaseHandler.plans[0]
                loading = false
            }
        }
    }
}


struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(plans: [
            .init(id: "0", title: "Monthly", subText: "Our most affordable plan", price: "2.99", billingType: "Recurring Billing", billingPeriod: "Month", index: 0),
            .init(id: "1", title: "Yearly", subText: "Save 30%", price: "24.99", billingType: "Recurring Billing", billingPeriod: "Year", index: 1),
            .init(id: "2", title: "Lifetime Deal", subText: "One-time payment", price: "49.99", billingType: "One Time Payment", billingPeriod: "Once", index: 2)
        ], views: [
            .init(view: AnyView(RemindersPromotionView()), maxWidth: 300),
            .init(view: AnyView(ListsPromotionView()), maxWidth: 300),
            .init(view: AnyView(TagsPromotionView())),
            .init(view: AnyView(IndieDevPromotion()), maxWidth: 400)
        ], selectedPlan: nil)
    }
}
