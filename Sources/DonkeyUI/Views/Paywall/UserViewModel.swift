//
//  UserViewModel.swift
//  Magic Weather SwiftUI
//
//  Created by Cody Kerns on 1/19/21.
//
import Foundation
import RevenueCat
import SwiftUI

public enum PaywallDataState {
    case loading,
    offline,
    loaded
}

/* Static shared model for UserView */
public class UserViewModel: ObservableObject {
    @AppStorage("firstAppOpen") var firstAppOpen = true
    public static let shared = UserViewModel()
    var etitlementId: String = "Premium"
    
    
    @Published public var isLoading: Bool = true
    @Published public var showNetworkError = false
    
    /* The latest CustomerInfo from RevenueCat. Updated by PurchasesDelegate whenever the Purchases SDK updates the cache */
    @Published public var customerInfo: CustomerInfo? {
        didSet {
            subscriptionActive = customerInfo?.entitlements[self.etitlementId]?.isActive == true
            print("Subscription active?")
            print(subscriptionActive)
            print(customerInfo?.entitlements.active ?? "null")
        }
    }
    
    public func setProEntitlementId(id: String) {
        self.etitlementId = id
    }
    
    
    @Published public var paywallOn = false
    
    
    public func verifyPaywallData() -> PaywallDataState{
        
        if self.offerings == nil {
            // check if loading, or offline
            self.showNetworkError = true
            
        }
        return .loaded
    }
    
    
    public func openPaywall() {
        if offerings == nil {
            // show error
            self.showNetworkError = true
            return
        }
        self.paywallOn = true
    }
    
    
    public func premiumCheckWithSheetSwitch(closeAction: @escaping () -> Void, accessAction: @escaping () -> Void) {
        if subscriptionActive {
            accessAction()
        } else {
            closeAction()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.openPaywall()
            }
        }
    }
    
    public func premiumCheck(action: @escaping () -> Void) {
        if subscriptionActive {
            action()
        } else {
            self.openPaywall()
        }
    }
    
    
    public func firstAppOpenPaywall() {
        if firstAppOpen {
            self.openPaywall()
            firstAppOpen = false
        }
    }
    
    /* Set from the didSet method of customerInfo above, based on the entitlement set in Constants.swift */
    @Published public var subscriptionActive: Bool = false
    
    @Published public var offerings: Offerings? = nil
    /*
     How to login and identify your users with the Purchases SDK.
     
     These functions mimic displaying a login dialog, identifying the user, then logging out later.
     
     Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids
     */
    public func login(userId: String) async {
        _ = try? await Purchases.shared.logIn(userId)
    }
    
    public func logout() async {
        /**
         The current user ID is no longer valid for your instance of *Purchases* since the user is logging out, and is no longer authorized to access customerInfo for that user ID.
         
         `logOut` clears the cache and regenerates a new anonymous user ID.
         
         - Note: Each time you call `logOut`, a new installation will be logged in the RevenueCat dashboard as that metric tracks unique user ID's that are in-use. Since this method generates a new anonymous ID, it counts as a new user ID in-use.
         */
        _ = try? await Purchases.shared.logOut()
    }
}
