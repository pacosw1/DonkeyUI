import Foundation
import RevenueCat

@MainActor
class PurchaseHandler: ObservableObject {
//    @Published var offerings: Offerings? = nil
    @Published var loadingPurchaseScreen: Bool = false
    @Published var showErrorMessage: Bool = false
    @Published var errorMessage: String = "Connection Error"

    // Fetch products from RevenueCat API
    private func handleError(error: PublicError?) {
        self.errorMessage = error?.localizedDescription ?? self.errorMessage
        self.showErrorMessage = true
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
    
    
    func restorePurchases() {
        self.loadingPurchaseScreen = true
        Purchases.shared.restorePurchases { customerInfo, genericError in
        
            if let error = genericError as? RevenueCat.ErrorCode {
                
                if error != .purchaseCancelledError && error != .missingReceiptFileError {
                    self.handleError(error: genericError)
                }
            }
            //TODO check if restored, show success message.
            //TODO check if not restored, show no purchases message
            //TODO handle errors
            //... check customerInfo to see if entitlement is now active
            self.loadingPurchaseScreen = false
        }
    }
    
    func initiatePurchase(package: Package?, successAction: @escaping() -> Void, errorAction: @escaping (PublicError?, Bool) -> Void) {
        
        guard let concretePackage = package else {
            errorMessage = "Unknown Error"
            self.loadingPurchaseScreen = false
            self.showErrorMessage = true
            return
        }
        
        Purchases.shared.purchase(package: concretePackage) { (transaction, customerInfo, error, userCancelled) in
            if customerInfo?.entitlements[UserViewModel.shared.etitlementId]?.isActive == true {
                // Unlock that great "pro" content
                UserViewModel.shared.subscriptionActive = true
                self.loadingPurchaseScreen = false
            } else {
                // Handle error gracefully
                
                if error != nil && !userCancelled {
                    errorAction(error, userCancelled)
                    self.handlePurchaseError(code: error as? RevenueCat.ErrorCode ?? .networkError)
                }
                self.loadingPurchaseScreen = false
            }
            
        }
    }
    
    // Todo implement this and reflect it with an icon in error toast
    private func handlePurchaseError(code: RevenueCat.ErrorCode) {
        //Todo switch icons
        switch code {
        case .networkError:
            self.errorMessage = "Connection Error"
            break
        case .storeProblemError:
            self.errorMessage = "Error connecting to Appstore"
            break
        case .offlineConnectionError:
            self.errorMessage = "You are offline"
            break
        case .logOutAnonymousUserError:
            self.errorMessage = "AppleID not setup"
            break;
        case .invalidAppUserIdError:
            self.errorMessage = "Not logged in with AppleID"
        default:
            self.errorMessage = "Unkown Error"
            break
        }
        
        self.showErrorMessage = true
    }
    
    public func fetchProducts() async -> [PaywallPlan] {
        var plans: [PaywallPlan] = []
        var offerings = UserViewModel.shared.offerings
        
        if offerings == nil {
            do {
                offerings = try await Purchases.shared.offerings()
            } catch {
                print(error)
                return []
            }
        }
        
        if let packages = offerings?.current?.availablePackages {
            
            var index = 0
                // Map items to paywall UI
            for package in packages {
                // Map cause we need this for api call later
                self.packageMap[package.id] = package
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
        
        return plans
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
