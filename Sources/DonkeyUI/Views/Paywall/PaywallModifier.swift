//
//  BorderModifier.swift
//  Divergent
//
//  Created by paco on 26/11/22.
//
import SwiftUI
import RevenueCat

public struct PaywallModifier: ViewModifier {
    
    public init(user: UserViewModel = UserViewModel.shared, views: [IdentifiableView], successAction: @escaping () -> Void, errorAction: @escaping (PublicError?, Bool) -> Void) {
        self.user = user
        self.views = views
        self.successAction = successAction
        self.errorAction = errorAction
    }
    
    @ObservedObject var user = UserViewModel.shared
    var views: [IdentifiableView]
    var successAction: () -> Void
    var errorAction: (PublicError?, Bool) -> Void
    
    
    public func body(content: Content) -> some View {
        content
            .errorToast(presented: $user.showNetworkError)
            .fullScreenCover(isPresented: $user.paywallOn) {
                PaywallView(views: views, successAction: successAction, errorAction: errorAction, proEntitlementId: UserViewModel.shared.etitlementId)
            }
      }
}

public extension View {
    func paywall(views: [IdentifiableView] = [], successAction: @escaping () -> Void, errorAction:  @escaping (PublicError?, Bool) -> Void) -> some View {
        modifier(PaywallModifier(views: views, successAction: successAction, errorAction: errorAction))
    }
}
    
