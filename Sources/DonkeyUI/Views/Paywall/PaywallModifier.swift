//
//  BorderModifier.swift
//  Divergent
//
//  Created by paco on 26/11/22.
//
import SwiftUI
import RevenueCat

struct PaywallModifier: ViewModifier {
    @ObservedObject var user = UserViewModel.shared
    var views: [IdentifiableView]
    var successAction: () -> Void
    var errorAction: (PublicError?, Bool) -> Void
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $user.paywallOn) {
                PaywallView(views: views, successAction: successAction, errorAction: errorAction, proEntitlementId: UserViewModel.shared.etitlementId)
            }
      }
}

extension View {
    func paywall(views: [IdentifiableView] = [], successAction: @escaping () -> Void, errorAction:  @escaping (PublicError?, Bool) -> Void) -> some View {
        modifier(PaywallModifier(views: views, successAction: successAction, errorAction: errorAction))
    }
}
    
