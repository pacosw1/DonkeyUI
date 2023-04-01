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
    @Published private var packageMap = [String: Package]()
    @Published public var subscriptionActive: Bool = false
    @Published public var offerings: Offerings? = nil
    @Published public var paywallOn = false
    
    /* The latest CustomerInfo from RevenueCat. Updated by PurchasesDelegate whenever the Purchases SDK updates the cache */
    @Published public var customerInfo: CustomerInfo? {
        didSet {
            subscriptionActive = customerInfo?.entitlements[self.etitlementId]?.isActive == true
            UserDefaults.standard.set(subscriptionActive, forKey: "isSubscribed")

            print("Subscription active?")
            print(subscriptionActive)
            print(customerInfo?.entitlements.active ?? "null")
        }
    }
    
    public func setProEntitlementId(id: String) {
        self.etitlementId = id
    }
    
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
    
    public func premiumCheck(action: () -> Void) {
        if self.subscriptionActive == true {
            print("Subscription is active")
            action()
        } else {
            self.openPaywall()
        }
    }
    
    public func getOfferings() async {
        offerings = try? await Purchases.shared.offerings()
    }
    
    public func getPackage(packageId: String) -> Package? {
        return offerings?.current?.package(identifier: packageId)
    }
    
    public func initializeAppChecks() async {
        // Initialize last known subscription state
        let isSubscribed = UserDefaults.standard.bool(forKey: "isSubscribed")
        DispatchQueue.main.async {
            self.subscriptionActive = isSubscribed
        }
        
        // Check subscription end date to make sure this is correct.
//        let isSubscribed = UserDefaults.standard.integer(forKey: "subscription")
        if isSubscribed {
            if let expirationTimestamp = UserDefaults.standard.object(forKey: "subscriptionExpirationDate") as? TimeInterval {
                let expirationDate = Date(timeIntervalSince1970: expirationTimestamp)
                // Use expirationDate as needed
                if Date.now >= expirationDate {
                    
                    do {
                        let customerInfo = try await Purchases.shared.syncPurchases()
                        DispatchQueue.main.async {
                            self.customerInfo = customerInfo
                        }
                        let stillSubscribed = self.customerInfo?.entitlements[self.etitlementId]?.isActive == true
                        if stillSubscribed {
                            if let newExpiration = self.customerInfo?.expirationDate(forEntitlement: self.etitlementId) {
                                UserDefaults.standard.set(newExpiration.timeIntervalSince1970, forKey: "subscriptionExpirationDate")
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.subscriptionActive = false
                                UserDefaults.standard.set(false, forKey: "isSubscribed")

                            }
                        }
                    } catch {
                        // do nothing
                    }
                }
            }
        }
        let offerings = try? await Purchases.shared.offerings()
        DispatchQueue.main.async {
            self.offerings = offerings
        }
        
        if firstAppOpen {
            if offerings != nil {
                DispatchQueue.main.async {
                    self.paywallOn = true
                    self.firstAppOpen = false
                }
            }
        }
    }
    
    /* Set from the didSet method of customerInfo above, based on the entitlement set in Constants.swift */
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
