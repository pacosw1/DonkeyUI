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
    var isSheet: Bool
    
    @ObservedObject var purchaseHandler: PurchaseHandler
    
    @State var loading: Bool = false
    @State var selectedPlan: PaywallPlan?
    @State var progress: CGFloat = 0
    @State var plans: [PaywallPlan] = []
    @State var packageMap = [String: Package]()


    public init(views: [IdentifiableView] = [], successAction: @escaping () -> Void, errorAction: (PublicError?, Bool) -> Void, closeAction: @escaping () -> Void = {}, proEntitlementId: String, isSheet: Bool = false) {
        self.views = views
        self.closeAction = closeAction
        self.selectedPlan = nil
        self.purchaseHandler = PurchaseHandler()
        self.isSheet = isSheet
    }
    
    
    func getPackage(packageId: String?) -> Package? {
        return UserViewModel.shared.offerings!.current!.package(identifier: packageId)
    }
    
    public var body: some View {
            
            VStack {
                
                PaywallHeaderView(closeAction: closeAction, isSheet: isSheet)


                Divider()
                PaywallFeatureSectionView(views: views)
                PaywallPlanSectionView(plans: plans, selectedPlan: $selectedPlan)
                PaywallActionView(selectePrice: selectedPlan?.price ?? "9", billingType: selectedPlan?.billingType ?? "", billingPeriod: selectedPlan?.billingPeriod ?? "", buyAction: {
                    purchaseHandler.initiatePurchase(package: getPackage(packageId: selectedPlan.id), successAction: successAction, errorAction: errorAction)
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
                        if !isSheet {
                            HStack {
                                Spacer()
                                CloseButton(action: {closeAction()})
                            }
                            .padding(.trailing)
                            .padding(.top)
                        }
                        Spacer()
                        HStack {
                            Spacer()
//                            SpinnerLoadingView()
                            ProgressBarView(fullWidth: true, progress: progress)
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
                ZStack {
                    Color.black.opacity(0.8)
                    SpinnerLoadingView()
                }
                .ignoresSafeArea()
                .opacity(purchaseHandler.loadingPurchaseScreen ? 1 : 0)
                .animation(.interactiveSpring(), value: purchaseHandler.loadingPurchaseScreen)

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
                
            
            plans = await self.purchaseHandler.fetchProducts()
            if !plans.isEmpty  {
                selectedPlan = plans[0]
            }
            loading = false
        }
            .errorToast(errorMessage: purchaseHandler.errorMessage, presented: $purchaseHandler.showErrorMessage)

    }
}


struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(
            views: [
            .init(view: AnyView(RemindersPromotionView()), maxWidth: 300),
            .init(view: AnyView(ListsPromotionView()), maxWidth: 300),
            .init(view: AnyView(TagsPromotionView())),
            .init(view: AnyView(IndieDevPromotion()), maxWidth: 400)
        ], successAction: {}, errorAction: {_,_ in}, proEntitlementId: "Premium", isSheet: true)
        .preferredColorScheme(.dark)
    }
}
