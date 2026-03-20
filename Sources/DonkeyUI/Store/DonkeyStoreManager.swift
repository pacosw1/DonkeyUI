//
//  DonkeyStoreManager.swift
//  Universal StoreKit 2 manager with multi-tier support.
//
//  Simple usage (single tier):
//     let store = DonkeyStoreManager(config: StoreConfig(productIDs: ["monthly", "yearly"]))
//     if store.isPro { ... }
//
//  Multi-tier usage (free / legacy lifetime / pro subscriber):
//     let store = DonkeyStoreManager(config: StoreConfig(
//         tiers: [
//             StoreTier(name: "premium", productIDs: ["lifetime_deal"], features: ["unlimited_local"]),
//             StoreTier(name: "pro", productIDs: ["month", "yearly"], features: ["unlimited_local", "cloud", "ai"]),
//         ],
//         promoProductIDs: ["month_promo", "yearly_promo"]  // maps to "pro" tier
//     ))
//     store.hasFeature("cloud")      // true only for pro subscribers
//     store.hasFeature("unlimited_local")  // true for both premium and pro
//     store.currentTier              // "pro", "premium", or "free"
//     store.isSubscriber             // true if active auto-renewable subscription
//     store.isLifetimePurchaser      // true if non-consumable lifetime purchase
//

import StoreKit
import SwiftUI
import os.log

private let logger = Logger(subsystem: "DonkeyUI", category: "Store")

// MARK: - Tier Definition

/// A named product tier with associated product IDs and feature flags.
public struct StoreTier: Sendable {
    public let name: String
    public let productIDs: Set<String>
    public let features: Set<String>
    /// Higher priority tiers override lower ones (pro > premium > free)
    public let priority: Int

    public init(name: String, productIDs: Set<String>, features: Set<String>, priority: Int? = nil) {
        self.name = name
        self.productIDs = productIDs
        self.features = features
        self.priority = priority ?? 0
    }
}

// MARK: - Configuration

/// Configuration for DonkeyStoreManager. Supports simple (flat) and multi-tier setups.
public struct StoreConfig: Sendable {
    public let tiers: [StoreTier]
    public let promoProductIDs: Set<String>
    public let promoTargetTier: String?
    public let userDefaultsSuite: String?
    public let isPurchasedKey: String

    /// All product IDs across all tiers + promo
    public var allProductIDs: Set<String> {
        var ids = promoProductIDs
        for tier in tiers { ids.formUnion(tier.productIDs) }
        return ids
    }

    /// Simple init — single tier, all product IDs grant "pro" access.
    public init(
        productIDs: Set<String>,
        userDefaultsSuite: String? = nil,
        isPurchasedKey: String = "donkey_isPro"
    ) {
        self.tiers = [StoreTier(name: "pro", productIDs: productIDs, features: ["all"], priority: 1)]
        self.promoProductIDs = []
        self.promoTargetTier = nil
        self.userDefaultsSuite = userDefaultsSuite
        self.isPurchasedKey = isPurchasedKey
    }

    /// Multi-tier init — define named tiers with features, optional promo products.
    public init(
        tiers: [StoreTier],
        promoProductIDs: Set<String> = [],
        promoTargetTier: String? = nil,
        userDefaultsSuite: String? = nil,
        isPurchasedKey: String = "donkey_isPro"
    ) {
        // Auto-assign priorities based on order if not explicitly set
        self.tiers = tiers.enumerated().map { i, tier in
            StoreTier(name: tier.name, productIDs: tier.productIDs, features: tier.features,
                      priority: tier.priority > 0 ? tier.priority : i + 1)
        }
        self.promoProductIDs = promoProductIDs
        self.promoTargetTier = promoTargetTier ?? tiers.last?.name
        self.userDefaultsSuite = userDefaultsSuite
        self.isPurchasedKey = isPurchasedKey
    }
}

// MARK: - Callbacks

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

    /// All loaded products (sorted: yearly > monthly > lifetime > consumable)
    public private(set) var products: [Product] = []

    /// Promo products (loaded separately on demand)
    public private(set) var promoProducts: [Product] = []

    /// Currently purchased (active) product IDs
    public private(set) var purchasedProductIDs: Set<String> = []

    /// Loading / error / purchasing state
    public private(set) var isLoadingProducts = false
    public private(set) var error: String?
    public private(set) var isPurchasing = false

    /// Paywall state — apps can bind to this
    public var showPaywall = false
    public var showPromoPaywall = false

    // MARK: - Tier-Based Access

    /// The highest-priority active tier, or "free" if none.
    public var currentTier: String {
        let activeTiers = config.tiers
            .filter { tier in
                let allTierIDs = tier.productIDs.union(
                    tier.name == config.promoTargetTier ? config.promoProductIDs : []
                )
                return !purchasedProductIDs.isDisjoint(with: allTierIDs)
            }
            .sorted { $0.priority > $1.priority }
        return activeTiers.first?.name ?? "free"
    }

    /// Simple boolean — any paid tier active (backwards compatible)
    public var isPro: Bool {
        !purchasedProductIDs.isEmpty
            || (activeSubscription?.isInGracePeriod ?? false)
            || (activeSubscription?.isInBillingRetry ?? false)
    }

    /// Has an active auto-renewable subscription (not lifetime)
    public var isSubscriber: Bool {
        purchasedProductIDs.contains { id in
            products.first(where: { $0.id == id })?.type == .autoRenewable
        }
    }

    /// Has a non-consumable lifetime purchase
    public var isLifetimePurchaser: Bool {
        purchasedProductIDs.contains { id in
            products.first(where: { $0.id == id })?.type == .nonConsumable
        }
    }

    /// Check if the user has a specific feature (from tier definitions).
    public func hasFeature(_ feature: String) -> Bool {
        // "all" grants everything (simple single-tier config)
        let activeTiers = config.tiers.filter { tier in
            let allTierIDs = tier.productIDs.union(
                tier.name == config.promoTargetTier ? config.promoProductIDs : []
            )
            return !purchasedProductIDs.isDisjoint(with: allTierIDs)
        }
        return activeTiers.contains { $0.features.contains("all") || $0.features.contains(feature) }
    }

    /// Premium check — runs action if has feature, shows paywall if not.
    public func premiumCheck(feature: String = "all", action: @escaping () -> Void) {
        if hasFeature(feature) || isPro {
            action()
        } else {
            showPaywall = true
        }
    }

    // MARK: - Subscription Details

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

        let cached = defaults.bool(forKey: config.isPurchasedKey)
        if cached {
            purchasedProductIDs = ["__cached__"]
        }

        transactionListener = listenForTransactions()

        Task {
            await loadProducts()
            await updateEntitlements()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    /// Load main products. Retries once on failure.
    public func loadProducts(forceReload: Bool = false) async {
        guard !productsLoaded || forceReload else { return }
        isLoadingProducts = true
        error = nil

        // Load main tier products
        let mainIDs = config.tiers.reduce(into: Set<String>()) { $0.formUnion($1.productIDs) }

        do {
            products = try await Product.products(for: mainIDs)
            products.sort { sortOrder($0) < sortOrder($1) }
            productsLoaded = true
            logger.info("Loaded \(self.products.count) products")
        } catch {
            logger.error("Failed to load products: \(error). Retrying...")
            try? await Task.sleep(for: .seconds(2))
            do {
                products = try await Product.products(for: mainIDs)
                products.sort { sortOrder($0) < sortOrder($1) }
                productsLoaded = true
            } catch {
                self.error = "Could not load products. Check your connection."
                logger.error("Failed to load products on retry: \(error)")
            }
        }

        isLoadingProducts = false
    }

    /// Load promo products on demand (separate from main products).
    public func loadPromoProducts() async -> [Product] {
        guard !config.promoProductIDs.isEmpty else { return [] }
        do {
            let promo = try await Product.products(for: config.promoProductIDs)
            promoProducts = promo.sorted { $0.price < $1.price }
            return promoProducts
        } catch {
            logger.error("Failed to load promo products: \(error)")
            return []
        }
    }

    // MARK: - Purchase

    @discardableResult
    public func purchase(_ product: Product) async -> PurchaseResult {
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
                await callbacks.onSubscriptionChange(product.id, "active", transaction.expirationDate)

                logger.info("Purchase successful: \(product.id)")
                return .success(transaction)

            case .userCancelled:
                return .cancelled
            case .pending:
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

    public func updateEntitlements() async {
        guard !isUpdatingEntitlements else { return }
        isUpdatingEntitlements = true
        defer { isUpdatingEntitlements = false }

        var purchased: Set<String> = []
        var latestPurchaseDate: Date = .distantPast

        // Collect from currentEntitlements — includes promo product IDs
        for await result in Transaction.currentEntitlements {
            // Accept unverified in DEBUG for Xcode StoreKit testing
            let transaction: StoreKit.Transaction
            switch result {
            case .verified(let t): transaction = t
            case .unverified(let t, _):
                #if DEBUG
                logger.info("Accepting unverified transaction: \(t.productID)")
                transaction = t
                #else
                continue
                #endif
            }

            if transaction.revocationDate == nil {
                purchased.insert(transaction.productID)
            }
        }

        // Get subscription status details
        var latestSubscription: ActiveSubscription?

        for product in products where product.type == .autoRenewable {
            guard let statuses = try? await product.subscription?.status else { continue }

            for status in statuses {
                guard case .verified(let renewalInfo) = status.renewalInfo,
                      case .verified(let transaction) = status.transaction else { continue }
                guard transaction.revocationDate == nil else { continue }

                if latestSubscription == nil || transaction.purchaseDate > latestPurchaseDate {
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

                    if status.state == .subscribed || status.state == .inGracePeriod || status.state == .inBillingRetryPeriod {
                        purchased.insert(transaction.productID)
                    }
                }
            }
        }

        purchasedProductIDs = purchased
        activeSubscription = latestSubscription

        defaults.set(isPro, forKey: config.isPurchasedKey)

        // Notify server with tier-aware status
        let tierName = currentTier
        if let sub = latestSubscription {
            let status: String
            if sub.isInTrial { status = "\(tierName)_trial" }
            else if sub.isInGracePeriod { status = "\(tierName)_grace_period" }
            else if sub.isInBillingRetry { status = "\(tierName)_billing_retry" }
            else { status = tierName }
            await callbacks.onSubscriptionChange(sub.productID, status, sub.expirationDate)
        } else if isLifetimePurchaser {
            await callbacks.onSubscriptionChange(purchasedProductIDs.first ?? "", tierName, nil)
        } else if purchased.isEmpty {
            await callbacks.onSubscriptionChange("", "free", nil)
        }
    }

    // MARK: - Helpers

    public func product(for id: String) -> Product? {
        products.first(where: { $0.id == id }) ?? promoProducts.first(where: { $0.id == id })
    }

    public var sortedProducts: [Product] { products }

    public var subscriptionProducts: [Product] {
        products.filter { $0.type == .autoRenewable }
    }

    public static func savingsPercentage(yearly: Product, monthly: Product) -> Int? {
        let yearlyPrice = yearly.price
        let monthlyAnnualized = monthly.price * 12
        guard monthlyAnnualized > 0 else { return nil }
        let savings = ((monthlyAnnualized - yearlyPrice) / monthlyAnnualized) * 100
        return Int(NSDecimalNumber(decimal: savings).doubleValue.rounded())
    }

    public static func monthlyEquivalent(_ yearly: Product) -> Decimal? {
        guard yearly.type == .autoRenewable else { return nil }
        return yearly.price / 12
    }

    // MARK: - Debug

    #if DEBUG
    public func debugGrantPro() {
        purchasedProductIDs = ["debug_pro"]
        defaults.set(true, forKey: config.isPurchasedKey)
    }

    public func debugClearPurchases() {
        purchasedProductIDs = []
        activeSubscription = nil
        defaults.set(false, forKey: config.isPurchasedKey)
    }

    public func debugSetTier(_ tierName: String) {
        if let tier = config.tiers.first(where: { $0.name == tierName }),
           let firstID = tier.productIDs.first {
            purchasedProductIDs = [firstID]
            defaults.set(true, forKey: config.isPurchasedKey)
        }
    }
    #endif

    // MARK: - Private

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.unfinished {
                switch result {
                case .verified(let transaction):
                    await transaction.finish()
                case .unverified(let transaction, _):
                    await transaction.finish()
                }
            }

            for await result in Transaction.updates {
                guard let self else { return }
                switch result {
                case .verified(let transaction):
                    await transaction.finish()
                case .unverified(let transaction, _):
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
