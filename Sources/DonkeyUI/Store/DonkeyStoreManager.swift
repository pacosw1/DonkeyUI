//
//  DonkeyStoreManager.swift
//  The one StoreKit 2 manager to rule them all.
//
//  Usage:
//  1. Create with your product IDs:
//     let store = DonkeyStoreManager(config: StoreConfig(productIDs: ["com.app.monthly", "com.app.yearly"]))
//
//  2. Inject into environment:
//     ContentView().environment(store)
//
//  3. Use in views:
//     @Environment(DonkeyStoreManager.self) var store
//     if store.isPro { ... }
//     await store.purchase(product)
//

import StoreKit
import SwiftUI
import os.log

private let logger = Logger(subsystem: "DonkeyUI", category: "Store")

// MARK: - Configuration

/// Configuration for DonkeyStoreManager. Pass at init.
public struct StoreConfig: Sendable {
    public let productIDs: Set<String>
    public let userDefaultsSuite: String?
    public let isPurchasedKey: String

    public init(
        productIDs: Set<String>,
        userDefaultsSuite: String? = nil,
        isPurchasedKey: String = "donkey_isPro"
    ) {
        self.productIDs = productIDs
        self.userDefaultsSuite = userDefaultsSuite
        self.isPurchasedKey = isPurchasedKey
    }
}

// MARK: - Callbacks

/// Optional callbacks for server sync, analytics, etc.
/// Apps provide their own implementation — no hardcoded APIClient.
public struct StoreCallbacks: Sendable {
    public let onPurchaseComplete: @Sendable (StoreKit.Transaction, Product) async -> Void
    public let onRestoreComplete: @Sendable (Set<String>) async -> Void
    public let onSubscriptionChange: @Sendable (String, String, Date?) async -> Void

    public init(
        onPurchaseComplete: @escaping @Sendable (StoreKit.Transaction, Product) async -> Void = { _, _ in },
        onRestoreComplete: @escaping @Sendable (Set<String>) async -> Void = { _ in },
        onSubscriptionChange: @escaping @Sendable (String, String, Date?) async -> Void = { _, _, _ in }
    ) {
        self.onPurchaseComplete = onPurchaseComplete
        self.onRestoreComplete = onRestoreComplete
        self.onSubscriptionChange = onSubscriptionChange
    }
}

// MARK: - Purchase Result

public enum PurchaseResult: Sendable {
    case success(StoreKit.Transaction)
    case pending
    case cancelled
    case failed(Error)
}

// MARK: - DonkeyStoreManager

@Observable
@MainActor
public final class DonkeyStoreManager {

    // MARK: - Public State

    /// All loaded products, sorted: yearly first, then monthly, then lifetime, then others
    public private(set) var products: [Product] = []

    /// Currently purchased (active) product IDs
    public private(set) var purchasedProductIDs: Set<String> = []

    /// Whether any active entitlement exists (includes grace period + billing retry)
    public var isPro: Bool {
        !purchasedProductIDs.isEmpty
            || (activeSubscription?.isInGracePeriod ?? false)
            || (activeSubscription?.isInBillingRetry ?? false)
    }

    /// Loading state
    public private(set) var isLoadingProducts = false

    /// Error state (nil = no error)
    public private(set) var error: String?

    /// Whether a purchase is currently in progress
    public private(set) var isPurchasing = false

    // MARK: - Subscription Details

    /// Active subscription details (nil if free/lifetime)
    public private(set) var activeSubscription: ActiveSubscription?

    public struct ActiveSubscription {
        public let productID: String
        public let expirationDate: Date?
        public let isInTrial: Bool
        public let willAutoRenew: Bool
        public let isInGracePeriod: Bool
        public let isInBillingRetry: Bool
        public let originalTransactionID: UInt64
    }

    // MARK: - Private

    private let config: StoreConfig
    private let callbacks: StoreCallbacks
    private let defaults: UserDefaults
    private nonisolated(unsafe) var transactionListener: Task<Void, Never>?
    private var productsLoaded = false
    private var isUpdatingEntitlements = false

    // MARK: - Init

    public init(config: StoreConfig, callbacks: StoreCallbacks = StoreCallbacks()) {
        self.config = config
        self.callbacks = callbacks

        if let suite = config.userDefaultsSuite {
            self.defaults = UserDefaults(suiteName: suite) ?? .standard
        } else {
            self.defaults = .standard
        }

        // Load cached isPro for instant UI (before entitlements load)
        let cached = defaults.bool(forKey: config.isPurchasedKey)
        if cached {
            purchasedProductIDs = ["__cached__"]
        }

        // Listener is assigned synchronously in init (safe for nonisolated(unsafe))
        // It drains unfinished transactions first, then listens for updates
        transactionListener = listenForTransactions()

        // Load products and check entitlements
        Task {
            await loadProducts()
            await updateEntitlements()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    /// Load products from App Store. Retries once on failure.
    public func loadProducts(forceReload: Bool = false) async {
        guard !productsLoaded || forceReload else { return }
        isLoadingProducts = true
        error = nil

        do {
            products = try await Product.products(for: config.productIDs)
            products.sort { sortOrder($0) < sortOrder($1) }
            productsLoaded = true
            logger.info("Loaded \(self.products.count) products")
        } catch {
            logger.error("Failed to load products: \(error). Retrying...")
            try? await Task.sleep(for: .seconds(2))
            do {
                products = try await Product.products(for: config.productIDs)
                products.sort { sortOrder($0) < sortOrder($1) }
                productsLoaded = true
                logger.info("Loaded \(self.products.count) products on retry")
            } catch {
                self.error = "Could not load products. Check your connection."
                logger.error("Failed to load products on retry: \(error)")
            }
        }

        isLoadingProducts = false
    }

    // MARK: - Purchase

    /// Purchase a product. Returns the result.
    @discardableResult
    public func purchase(_ product: Product) async -> PurchaseResult {
        // FIX #4: Guard against concurrent purchases
        guard !isPurchasing else { return .cancelled }
        isPurchasing = true
        error = nil

        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updateEntitlements()

                await callbacks.onPurchaseComplete(transaction, product)
                await callbacks.onSubscriptionChange(
                    product.id, "active", transaction.expirationDate
                )

                logger.info("Purchase successful: \(product.id)")
                return .success(transaction)

            case .userCancelled:
                logger.info("Purchase cancelled by user")
                return .cancelled

            case .pending:
                logger.info("Purchase pending (Ask to Buy / SCA)")
                return .pending

            @unknown default:
                return .cancelled
            }
        } catch {
            self.error = error.localizedDescription
            logger.error("Purchase failed: \(error)")
            return .failed(error)
        }
    }

    // MARK: - Restore

    /// Restore purchases. Shows error if nothing found.
    public func restore() async -> Bool {
        error = nil
        do {
            try await AppStore.sync()
            await updateEntitlements()
            await callbacks.onRestoreComplete(purchasedProductIDs)

            if isPro {
                logger.info("Restore successful: \(self.purchasedProductIDs)")
                return true
            } else {
                error = "No active purchases found."
                return false
            }
        } catch {
            self.error = "Could not restore purchases. Please try again."
            logger.error("Restore failed: \(error)")
            return false
        }
    }

    // MARK: - Entitlements

    /// Refresh entitlements from StoreKit. Called automatically on init and transaction updates.
    /// Protected against concurrent execution.
    public func updateEntitlements() async {
        // FIX #1: Guard against concurrent calls (purchase + listener can race)
        guard !isUpdatingEntitlements else { return }
        isUpdatingEntitlements = true
        defer { isUpdatingEntitlements = false }

        var purchased: Set<String> = []
        var latestPurchaseDate: Date = .distantPast

        // Step 1: Collect active entitlements from verified transactions
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.revocationDate == nil {
                purchased.insert(transaction.productID)
            }
        }

        // Step 2: Get detailed subscription status from Product.SubscriptionInfo
        var latestSubscription: ActiveSubscription?

        for product in products where product.type == .autoRenewable {
            guard let statuses = try? await product.subscription?.status else { continue }

            for status in statuses {
                guard case .verified(let renewalInfo) = status.renewalInfo,
                      case .verified(let transaction) = status.transaction else { continue }

                // FIX #6: Don't require purchased.contains — grace period may not show in currentEntitlements
                guard transaction.revocationDate == nil else { continue }

                let isNewer = transaction.purchaseDate > latestPurchaseDate

                if latestSubscription == nil || isNewer {
                    latestPurchaseDate = transaction.purchaseDate

                    latestSubscription = ActiveSubscription(
                        productID: transaction.productID,
                        expirationDate: transaction.expirationDate,
                        isInTrial: transaction.offerType == .introductory,
                        willAutoRenew: renewalInfo.willAutoRenew,
                        isInGracePeriod: status.state == .inGracePeriod,
                        isInBillingRetry: status.state == .inBillingRetryPeriod,
                        originalTransactionID: transaction.originalID
                    )

                    // FIX #6: Grant access from subscription status even if currentEntitlements missed it
                    if status.state == .subscribed || status.state == .inGracePeriod || status.state == .inBillingRetryPeriod {
                        purchased.insert(transaction.productID)
                    }
                }
            }
        }

        purchasedProductIDs = purchased
        activeSubscription = latestSubscription

        // Persist for fast UI checks (widgets, launch)
        defaults.set(isPro, forKey: config.isPurchasedKey)

        // Notify server of current state
        if let sub = latestSubscription {
            let status: String
            if sub.isInTrial { status = "trial" }
            else if sub.isInGracePeriod { status = "grace_period" }
            else if sub.isInBillingRetry { status = "billing_retry" }
            else { status = "active" }
            await callbacks.onSubscriptionChange(sub.productID, status, sub.expirationDate)
        } else if purchased.isEmpty {
            await callbacks.onSubscriptionChange("", "free", nil)
        }
    }

    // MARK: - Helpers

    /// Get a specific product by ID.
    public func product(for id: String) -> Product? {
        products.first(where: { $0.id == id })
    }

    /// Products sorted: yearly subscriptions first, then monthly, then lifetime, then consumables.
    public var sortedProducts: [Product] {
        products
    }

    /// Subscription products only (auto-renewable).
    public var subscriptionProducts: [Product] {
        products.filter { $0.type == .autoRenewable }
    }

    /// Format savings between two products (e.g. "Save 55%").
    public static func savingsPercentage(yearly: Product, monthly: Product) -> Int? {
        let yearlyPrice = yearly.price
        let monthlyAnnualized = monthly.price * 12
        guard monthlyAnnualized > 0 else { return nil }
        let savings = ((monthlyAnnualized - yearlyPrice) / monthlyAnnualized) * 100
        return Int(NSDecimalNumber(decimal: savings).doubleValue.rounded())
    }

    /// Price per month for a yearly subscription.
    public static func monthlyEquivalent(_ yearly: Product) -> Decimal? {
        guard yearly.type == .autoRenewable else { return nil }
        return yearly.price / 12
    }

    // MARK: - Debug Helpers

    #if DEBUG
    /// Grant pro access for testing (debug only).
    public func debugGrantPro() {
        purchasedProductIDs = ["debug_pro"]
        defaults.set(true, forKey: config.isPurchasedKey)
    }

    /// Clear all purchases for testing (debug only).
    public func debugClearPurchases() {
        purchasedProductIDs = []
        activeSubscription = nil
        defaults.set(false, forKey: config.isPurchasedKey)
    }
    #endif

    // MARK: - Private

    /// FIX #2 & #5: Single listener that drains unfinished transactions first,
    /// then listens for updates. Assigned synchronously in init (safe for deinit).
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            // Drain any unfinished transactions from prior sessions first
            for await result in Transaction.unfinished {
                switch result {
                case .verified(let transaction):
                    await transaction.finish()
                    logger.info("Finished pending transaction: \(transaction.productID)")
                case .unverified(let transaction, let error):
                    logger.warning("Unverified pending transaction \(transaction.id): \(error)")
                    await transaction.finish()
                }
            }

            // Now listen for new transaction updates
            for await result in Transaction.updates {
                guard let self else { return }
                switch result {
                case .verified(let transaction):
                    await transaction.finish()
                    logger.info("Transaction update: \(transaction.productID)")
                case .unverified(let transaction, let error):
                    logger.warning("Unverified transaction \(transaction.id): \(error)")
                    await transaction.finish()
                }
                await self.updateEntitlements()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let value): return value
        }
    }

    private func sortOrder(_ product: Product) -> Int {
        switch product.type {
        case .autoRenewable:
            if product.subscription?.subscriptionPeriod.unit == .year { return 0 }
            if product.subscription?.subscriptionPeriod.unit == .month { return 1 }
            return 2
        case .nonConsumable: return 3
        case .consumable: return 4
        default: return 5
        }
    }
}
