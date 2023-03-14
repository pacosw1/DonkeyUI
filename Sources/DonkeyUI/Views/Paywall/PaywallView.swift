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
    var successAction: () -> Void = {}
    var errorAction: (PublicError?, Bool) -> Void = {_, _ in}
    
    @ObservedObject var purchaseHandler: PurchaseHandler
    
    @State var loading: Bool = false
    @State var selectedPlan: PaywallPlan?
    @State var progress: CGFloat = 0
  
    public init(plans: [PaywallPlan] = [], views: [IdentifiableView] = [], successAction: @escaping () -> Void, errorAction: (PublicError?, Bool) -> Void, closeAction: @escaping () -> Void = {}, proEntitlementId: String) {
        self.views = views
        self.closeAction = closeAction
        self.selectedPlan = nil
        self.purchaseHandler = PurchaseHandler(entitlementId: proEntitlementId)
    }
    
    public var body: some View {
            
            VStack {
                
                PaywallHeaderView(closeAction: closeAction)


                Divider()
                PaywallFeatureSectionView(views: views)
                PaywallPlanSectionView(plans: purchaseHandler.plans, selectedPlan: $selectedPlan)
                PaywallActionView(selectePrice: selectedPlan?.price ?? "9", billingType: selectedPlan?.billingType ?? "", billingPeriod: selectedPlan?.billingPeriod ?? "", buyAction: {
                    purchaseHandler.initiatePurchase(selectedPackageId: selectedPlan!.id, successAction: successAction, errorAction: errorAction)
                }, isDisabled: loading || selectedPlan == nil || purchaseHandler.loadingPurchaseScreen, isLoading: purchaseHandler.loadingPurchaseScreen)
                Spacer()
                PaywallPolicyView(restorePurchasesAction: purchaseHandler.restorePurchases)
            }
        
            .onTapGesture {
                purchaseHandler.showErrorMessage = true
            }
            .overlay {
                ZStack {
                    Color(UIColor.systemBackground)
                        .ignoresSafeArea()
                    VStack {
                        HStack {
                            Spacer()
                            CloseButton(action: {closeAction()})
                        }
                        .padding(.trailing)
                        .padding(.top)
                        Spacer()
                        HStack {
                            Spacer()
//                            SpinnerLoadingView()
                            ProgressBarView(fullWidth: true, progress: $progress)
                                .padding(.horizontal, 50)
                                .padding(.bottom, 50)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .opacity(loading ? 1 : 0)
            }
            .overlay {
                Color.black.opacity(purchaseHandler.loadingPurchaseScreen ? 0.3 : 0)
                    .ignoresSafeArea()
            }
            .task {
//            Purchases.configure(withAPIKey: "")
            loading = true
                
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        progress = 0.2
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        progress = 0.6
                    }
                }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation {
                    progress = 0.89
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                withAnimation {
                    progress = 0.99
                }
            }
                
            
            let worked = await self.purchaseHandler.fetchProducts()
            if worked && !purchaseHandler.plans.isEmpty  {
                selectedPlan = purchaseHandler.plans[0]
                loading = true
            }
            loading = false
        }
            .errorToast(presented: $purchaseHandler.showErrorMessage)

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
        ], successAction: {}, errorAction: {_,_ in}, proEntitlementId: "Premium")
        .preferredColorScheme(.dark)
    }
}
