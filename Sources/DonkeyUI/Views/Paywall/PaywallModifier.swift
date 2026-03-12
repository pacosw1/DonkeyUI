//
//  BorderModifier.swift
//  Divergent
//
//  Created by paco on 26/11/22.
//
import SwiftUI
import RevenueCat

public struct PaywallModifier: ViewModifier {
    
    public init(user: UserViewModel = UserViewModel.shared, views: [IdentifiableView], successAction: @escaping () -> Void, onOpen: @escaping () -> Void, errorAction: @escaping (RevenueCat.ErrorCode?, Bool) -> Void, privacyUrl: String) {
        self.user = user
        self.views = views
        self.successAction = successAction
        self.privacyUrl = privacyUrl
        self.errorAction = errorAction
        self.onOpen = onOpen
    }
    
    @ObservedObject var user = UserViewModel.shared
    var views: [IdentifiableView]
    let privacyUrl: String
    var successAction: () -> Void
    var onOpen: () -> Void
    var errorAction: (RevenueCat.ErrorCode?, Bool) -> Void

    
    
    public func body(content: Content) -> some View {
        content
            .errorToast(presented: $user.showNetworkError)
            .fullScreenCover(isPresented: $user.paywallOn) {
                PaywallView(views: views, successAction: successAction, onOpen: onOpen, errorAction: errorAction, proEntitlementId: UserViewModel.shared.etitlementId, privacyUrl: privacyUrl)
            }
      }
}

public extension View {
    func paywall(views: [IdentifiableView] = [], successAction: @escaping () -> Void, onOpen: @escaping () -> Void, errorAction:  @escaping (RevenueCat.ErrorCode?, Bool) -> Void, privacyUrl: String) -> some View {
        modifier(PaywallModifier(views: views, successAction: successAction, onOpen: onOpen, errorAction: errorAction, privacyUrl: privacyUrl))
    }
}
    
