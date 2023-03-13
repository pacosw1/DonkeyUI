import Foundation
import RevenueCat

class PurchaseHandler: ObservableObject {
    @Published var offerings: Offerings? = nil
    @Published var plans: [PaywallPlan] = []
    
    // Fetch products from RevenueCat API
    func fetchProducts(revenueCatApi: Purchases) async -> Bool {
        do {
            offerings = try await revenueCatApi.offerings()
            self.convertOfferingsToUIOptions()
            return true
        } catch {
            // TODO
            print("Error fetching offerings: \(error)")
            return false
        }
    }
    
    
    private func getBillingPeriod(packageType: PackageType) -> String {
        switch packageType {
        case .lifetime:
            return "One Time"
        case .monthly:
            return "Month"
        case .annual:
            return "Year"
        default:
            return "Month"
        }
    }
    
    private func convertOfferingsToUIOptions() {
        var plans: [PaywallPlan] = []
        
            if let packages = offerings?.current?.availablePackages {
                
                var index = 0
                    // Map items to paywall UI
                for package in packages {
                    let plan = PaywallPlan(
                        id: package.id,
                        title: package.storeProduct.localizedTitle,
                        subText: package.storeProduct.localizedDescription,
                        price: package.localizedPriceString,
                        billingType: package.packageType == .lifetime ? "One Time Purchase" : "Recurring Billing",
                        billingPeriod: getBillingPeriod(packageType: package.packageType),
                        index: index
                    )
                    plans.append(plan)
                    index += 1
                }
            }
        
        self.plans = plans
    }
    
    // Login to make purchase
    func login(userId: String) async {
            _ = try? await Purchases.shared.logIn(userId)
    }
    
   func logout() async {
            /**
             The current user ID is no longer valid for your instance of *Purchases* since the user is logging out, and is no longer authorized to access customerInfo for that user ID.
             
             `logOut` clears the cache and regenerates a new anonymous user ID.
             
             - Note: Each time you call `logOut`, a new installation will be logged in the RevenueCat dashboard as that metric tracks unique user ID's that are in-use. Since this method generates a new anonymous ID, it counts as a new user ID in-use.
             */
            _ = try? await Purchases.shared.logOut()
        }
}
