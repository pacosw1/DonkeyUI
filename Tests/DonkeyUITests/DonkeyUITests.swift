import XCTest
import SwiftUI
@testable import DonkeyUI

final class DonkeyUITests: XCTestCase {

    // MARK: - Date Extension Tests

    func testStartOfDay() {
        let date = makeDate(year: 2025, month: 6, day: 15, hour: 14, minute: 30)
        let start = date.startOfDay
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: start)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testEndOfDay() {
        let date = makeDate(year: 2025, month: 6, day: 15, hour: 10)
        let end = date.endOfDay
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: end)
        XCTAssertEqual(components.hour, 23)
        XCTAssertEqual(components.minute, 59)
        XCTAssertEqual(components.second, 59)
    }

    func testTomorrow() {
        let date = makeDate(year: 2025, month: 6, day: 15)
        let tomorrow = date.tomorrow
        XCTAssertEqual(Calendar.current.component(.day, from: tomorrow), 16)
    }

    func testYesterday() {
        let date = makeDate(year: 2025, month: 6, day: 15)
        let yesterday = date.yesterday
        XCTAssertEqual(Calendar.current.component(.day, from: yesterday), 14)
    }

    func testTimeProperty() {
        let date = makeDate(year: 2025, month: 6, day: 15, hour: 9, minute: 5)
        let time = date.time
        XCTAssertEqual(time, "9:5")
    }

    func testTimePropertyMidnight() {
        let date = makeDate(year: 2025, month: 6, day: 15, hour: 0, minute: 0)
        let time = date.time
        XCTAssertEqual(time, "0:0")
    }

    func testGetDate() {
        let date = makeDate(year: 2025, month: 6, day: 15)
        let future = date.getDate(dayDifference: 5)
        XCTAssertEqual(Calendar.current.component(.day, from: future), 20)
    }

    func testGetDateNegative() {
        let date = makeDate(year: 2025, month: 6, day: 15)
        let past = date.getDate(dayDifference: -3)
        XCTAssertEqual(Calendar.current.component(.day, from: past), 12)
    }

    func testInRange() {
        let date = makeDate(year: 2025, month: 6, day: 15)
        let start = makeDate(year: 2025, month: 6, day: 10)
        let end = makeDate(year: 2025, month: 6, day: 20)
        XCTAssertTrue(date.inRange(start: start, end: end))
    }

    func testInRangeOutside() {
        let date = makeDate(year: 2025, month: 6, day: 25)
        let start = makeDate(year: 2025, month: 6, day: 10)
        let end = makeDate(year: 2025, month: 6, day: 20)
        XCTAssertFalse(date.inRange(start: start, end: end))
    }

    func testAddMinutes() {
        let date = makeDate(year: 2025, month: 6, day: 15, hour: 10, minute: 0)
        let result = date.addMinutes(minuteDifference: 30)
        let components = Calendar.current.dateComponents([.hour, .minute], from: result)
        XCTAssertEqual(components.hour, 10)
        XCTAssertEqual(components.minute, 30)
    }

    func testAddSeconds() {
        let date = makeDate(year: 2025, month: 6, day: 15, hour: 10, minute: 0)
        let result = date.addSeconds(secondDifference: 90)
        let components = Calendar.current.dateComponents([.minute, .second], from: result)
        XCTAssertEqual(components.minute, 1)
        XCTAssertEqual(components.second, 30)
    }

    func testStartOfMonth() {
        let date = makeDate(year: 2025, month: 6, day: 15)
        let start = date.startOfMonth
        let components = Calendar.current.dateComponents([.year, .month, .day], from: start)
        XCTAssertEqual(components.day, 1)
        XCTAssertEqual(components.month, 6)
    }

    func testEndOfMonth() {
        let date = makeDate(year: 2025, month: 6, day: 15)
        let end = date.endOfMonth
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: end)
        XCTAssertEqual(components.day, 30) // June has 30 days
        XCTAssertEqual(components.hour, 23)
        XCTAssertEqual(components.minute, 59)
        XCTAssertEqual(components.second, 59)
    }

    func testMonthDayYear() {
        let date = makeDate(year: 2025, month: 3, day: 22)
        XCTAssertEqual(date.month, 3)
        XCTAssertEqual(date.day, 22)
        XCTAssertEqual(date.year, 2025)
    }

    func testTimestamp() {
        let date = Date(timeIntervalSince1970: 1000.5)
        XCTAssertEqual(date.timestamp(), 1000500)
    }

    func testDistanceInTextToday() {
        let today = Date.now
        let result = today.distanceInText(date: today)
        XCTAssertEqual(result, "Today")
    }

    func testDistanceInTextYesterday() {
        let today = Date.now
        let yesterday = today.yesterday
        let result = today.distanceInText(date: yesterday)
        XCTAssertEqual(result, "Yesterday")
    }

    func testDistanceInTextTomorrow() {
        let today = Date.now
        let tomorrow = today.tomorrow
        let result = today.distanceInText(date: tomorrow)
        XCTAssertEqual(result, "Tomorrow")
    }

    func testTimeComponents() {
        let date = makeDate(year: 2025, month: 6, day: 15, hour: 14, minute: 30)
        let components = date.timeComponents
        XCTAssertEqual(components.hour, 14)
        XCTAssertEqual(components.minute, 30)
    }

    func testEndOfDayDoesNotCrash() {
        // Regression: this used to force-unwrap
        let dates = [
            makeDate(year: 2025, month: 1, day: 1),
            makeDate(year: 2025, month: 2, day: 28),
            makeDate(year: 2024, month: 2, day: 29), // leap year
            makeDate(year: 2025, month: 12, day: 31),
        ]
        for date in dates {
            _ = date.endOfDay // should not crash
            _ = date.tomorrow
            _ = date.yesterday
            _ = date.startOfMonth
            _ = date.endOfMonth
        }
    }

    // MARK: - Color Extension Tests

    func testColorFromHex6() {
        let color = Color(hex: "#FF0000")
        XCTAssertNotNil(color)
    }

    func testColorFromHex6NoHash() {
        let color = Color(hex: "00FF00")
        XCTAssertNotNil(color)
    }

    func testColorFromHex8() {
        let color = Color(hex: "#FF000080")
        XCTAssertNotNil(color)
    }

    func testColorFromHexInvalid() {
        let color = Color(hex: "XYZ")
        XCTAssertNil(color)
    }

    func testColorFromHexEmpty() {
        let color = Color(hex: "")
        XCTAssertNil(color)
    }

    func testColorFromHexWrongLength() {
        let color = Color(hex: "#FFF")
        XCTAssertNil(color)
    }

    func testToHexRoundTrip() {
        let original = Color(hex: "3366CC")
        XCTAssertNotNil(original)
        let hex = original?.toHex()
        XCTAssertNotNil(hex)
        // Round-trip: create from hex, convert back
        if let hex = hex {
            let roundTripped = Color(hex: hex)
            XCTAssertNotNil(roundTripped)
        }
    }

    func testToHexReturnsUppercaseString() {
        let color = Color(hex: "aabbcc")
        let hex = color?.toHex()
        XCTAssertNotNil(hex)
        if let hex = hex {
            XCTAssertEqual(hex, hex.uppercased())
        }
    }

    func testButtonTextDoesNotCrash() {
        let color = Color.blue
        _ = color.buttonText(darkMode: true)
        _ = color.buttonText(darkMode: false)
    }

    func testButtonBackgroundDoesNotCrash() {
        let color = Color.red
        _ = color.buttonBackground()
    }

    // MARK: - Number Extension Tests

    func testBalanceString() {
        let value: Double = 123.45
        let result = value.balanceString
        // Should contain some form of number formatting
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains("123"))
    }

    func testBalanceStringZero() {
        let value: Double = 0
        let result = value.balanceString
        XCTAssertFalse(result.isEmpty)
    }

    func testBalanceColor() {
        let positive: Double = 100
        let negative: Double = -50
        // Just verify they don't crash and return different values
        let posColor = positive.balanceColor
        let negColor = negative.balanceColor
        XCTAssertNotEqual(posColor.description, negColor.description)
    }

    func testPercentageLabel() {
        let value: Double = 75.5
        XCTAssertEqual(value.percentageLabel, "75.50%")
    }

    func testPercentageLabelZero() {
        let value: Double = 0
        XCTAssertEqual(value.percentageLabel, "0.00%")
    }

    func testBalanceStringWithSign() {
        let positive: Double = 250
        let negative: Double = -250
        let posResult = positive.balanceStringWithSign
        let negResult = negative.balanceStringWithSign
        XCTAssertTrue(posResult.contains("+"))
        XCTAssertTrue(negResult.contains("-"))
    }

    func testBalanceStringWithSignIfNegative() {
        let positive: Double = 100
        let negative: Double = -100
        let posResult = positive.balanceStringWithSignIfNegative
        let negResult = negative.balanceStringWithSignIfNegative
        XCTAssertFalse(posResult.contains("-"))
        XCTAssertTrue(negResult.contains("-"))
    }

    // MARK: - DonkeyUI Struct

    func testDonkeyUIInit() {
        let d = DonkeyUI()
        XCTAssertEqual(d.text, "Hello, World!")
    }

    // MARK: - PaywallPlanOption

    func testPaywallPlanOptionInit() {
        let plan = PaywallPlanOption(
            id: "monthly",
            title: "Monthly",
            subtitle: "Billed monthly",
            priceDisplay: "$4.99",
            period: "/month"
        )
        XCTAssertEqual(plan.id, "monthly")
        XCTAssertEqual(plan.title, "Monthly")
        XCTAssertEqual(plan.priceDisplay, "$4.99")
    }

    func testPaywallConfigInit() {
        let config = PaywallConfig(
            headline: "Go Pro",
            headlineAccent: "Today",
            subtitle: "Unlock everything"
        )
        XCTAssertEqual(config.headline, "Go Pro")
        XCTAssertEqual(config.headlineAccent, "Today")
    }

    func testPaywallReviewInit() {
        let review = PaywallReview(title: "Great app", username: "user1", description: "Love it", rating: 5)
        XCTAssertEqual(review.rating, 5)
        XCTAssertEqual(review.title, "Great app")
    }

    // MARK: - StoreConfig Tests

    func testStoreConfigInitWithDefaults() {
        let config = StoreConfig(productIDs: ["com.app.monthly", "com.app.yearly"])
        XCTAssertEqual(config.productIDs, ["com.app.monthly", "com.app.yearly"])
        XCTAssertNil(config.userDefaultsSuite)
        XCTAssertEqual(config.isPurchasedKey, "donkey_isPro")
    }

    func testStoreConfigInitWithCustomValues() {
        let config = StoreConfig(
            productIDs: ["com.app.lifetime"],
            userDefaultsSuite: "group.com.app",
            isPurchasedKey: "myapp_isPro"
        )
        XCTAssertEqual(config.productIDs, ["com.app.lifetime"])
        XCTAssertEqual(config.userDefaultsSuite, "group.com.app")
        XCTAssertEqual(config.isPurchasedKey, "myapp_isPro")
    }

    func testStoreConfigEmptyProductIDs() {
        let config = StoreConfig(productIDs: [])
        XCTAssertTrue(config.productIDs.isEmpty)
    }

    func testStoreConfigProductIDsAreSet() {
        // Duplicate IDs should collapse since productIDs is a Set
        let config = StoreConfig(productIDs: ["com.app.monthly", "com.app.monthly"])
        XCTAssertEqual(config.productIDs.count, 1)
    }

    // MARK: - StoreCallbacks Tests

    func testStoreCallbacksDefaultInit() {
        let callbacks = StoreCallbacks()
        // Defaults should be non-nil closures (they just do nothing)
        XCTAssertNotNil(callbacks.onPurchaseComplete)
        XCTAssertNotNil(callbacks.onRestoreComplete)
        XCTAssertNotNil(callbacks.onSubscriptionChange)
    }

    func testStoreCallbacksCustomInit() {
        var purchaseCalled = false
        var restoreCalled = false
        var changeCalled = false

        let callbacks = StoreCallbacks(
            onPurchaseComplete: { _, _ in purchaseCalled = true },
            onRestoreComplete: { _ in restoreCalled = true },
            onSubscriptionChange: { _, _, _ in changeCalled = true }
        )

        XCTAssertNotNil(callbacks.onPurchaseComplete)
        XCTAssertNotNil(callbacks.onRestoreComplete)
        XCTAssertNotNil(callbacks.onSubscriptionChange)
        // closures not called yet
        XCTAssertFalse(purchaseCalled)
        XCTAssertFalse(restoreCalled)
        XCTAssertFalse(changeCalled)
    }

    // MARK: - PurchaseResult Tests

    func testPurchaseResultCancelledCase() {
        let result = PurchaseResult.cancelled
        if case .cancelled = result {
            // expected
        } else {
            XCTFail("Expected .cancelled")
        }
    }

    func testPurchaseResultPendingCase() {
        let result = PurchaseResult.pending
        if case .pending = result {
            // expected
        } else {
            XCTFail("Expected .pending")
        }
    }

    func testPurchaseResultFailedCase() {
        let error = NSError(domain: "test", code: 42)
        let result = PurchaseResult.failed(error)
        if case .failed(let e) = result {
            XCTAssertEqual((e as NSError).code, 42)
        } else {
            XCTFail("Expected .failed")
        }
    }

    // MARK: - PaywallPlanOption Tests

    func testPaywallPlanOptionFullInit() {
        let plan = PaywallPlanOption(
            id: "yearly",
            title: "Yearly",
            subtitle: "Best value",
            priceDisplay: "$29.99",
            period: "/year",
            isBestValue: true,
            isTrial: true,
            trialDescription: "7-day free trial"
        )
        XCTAssertEqual(plan.id, "yearly")
        XCTAssertEqual(plan.title, "Yearly")
        XCTAssertEqual(plan.subtitle, "Best value")
        XCTAssertEqual(plan.priceDisplay, "$29.99")
        XCTAssertEqual(plan.period, "/year")
        XCTAssertTrue(plan.isBestValue)
        XCTAssertTrue(plan.isTrial)
        XCTAssertEqual(plan.trialDescription, "7-day free trial")
    }

    func testPaywallPlanOptionMinimalInit() {
        let plan = PaywallPlanOption(
            title: "Monthly",
            priceDisplay: "$4.99",
            period: "/month"
        )
        // Auto-generated ID should not be empty
        XCTAssertFalse(plan.id.isEmpty)
        XCTAssertEqual(plan.title, "Monthly")
        XCTAssertEqual(plan.subtitle, "") // default
        XCTAssertEqual(plan.priceDisplay, "$4.99")
        XCTAssertEqual(plan.period, "/month")
        XCTAssertFalse(plan.isBestValue) // default
        XCTAssertFalse(plan.isTrial) // default
        XCTAssertNil(plan.trialDescription) // default
    }

    func testPaywallPlanOptionDefaultIDsAreUnique() {
        let plan1 = PaywallPlanOption(title: "A", priceDisplay: "$1", period: "/m")
        let plan2 = PaywallPlanOption(title: "B", priceDisplay: "$2", period: "/y")
        XCTAssertNotEqual(plan1.id, plan2.id)
    }

    // MARK: - PaywallFeatureItem Tests

    func testPaywallFeatureItemSFSymbolInit() {
        let feature = PaywallFeatureItem(
            systemIcon: "star.fill",
            iconColor: .yellow,
            title: "Favorites",
            description: "Save your favorites"
        )
        XCTAssertFalse(feature.id.isEmpty)
        XCTAssertEqual(feature.title, "Favorites")
        XCTAssertEqual(feature.description, "Save your favorites")
        XCTAssertEqual(feature.boldWord, "") // default for SF Symbol init

        if case .system(let name) = feature.icon {
            XCTAssertEqual(name, "star.fill")
        } else {
            XCTFail("Expected .system icon")
        }
    }

    func testPaywallFeatureItemSFSymbolDefaultColor() {
        let feature = PaywallFeatureItem(
            systemIcon: "chart.bar",
            title: "Stats",
            description: "See your stats"
        )
        // iconColor defaults to .accentColor — just verify it doesn't crash
        XCTAssertNotNil(feature.iconColor)
    }

    func testPaywallFeatureItemEmojiInit() {
        let feature = PaywallFeatureItem(
            emoji: "🎯",
            color: .red,
            text: "Unlimited goals",
            boldWord: "Unlimited"
        )
        XCTAssertFalse(feature.id.isEmpty)
        XCTAssertEqual(feature.title, "Unlimited goals")
        XCTAssertEqual(feature.description, "") // empty for emoji init
        XCTAssertEqual(feature.boldWord, "Unlimited")

        if case .emoji(let e) = feature.icon {
            XCTAssertEqual(e, "🎯")
        } else {
            XCTFail("Expected .emoji icon")
        }
    }

    func testPaywallFeatureItemEmojiDefaultBoldWord() {
        let feature = PaywallFeatureItem(
            emoji: "✅",
            color: .green,
            text: "All features"
        )
        XCTAssertEqual(feature.boldWord, "")
    }

    func testFeatureIconSystemCase() {
        let icon = FeatureIcon.system(name: "bell.fill")
        if case .system(let name) = icon {
            XCTAssertEqual(name, "bell.fill")
        } else {
            XCTFail("Expected .system")
        }
    }

    func testFeatureIconEmojiCase() {
        let icon = FeatureIcon.emoji("🔥")
        if case .emoji(let e) = icon {
            XCTAssertEqual(e, "🔥")
        } else {
            XCTFail("Expected .emoji")
        }
    }

    // MARK: - SubscriptionDisplayInfo Tests

    func testSubscriptionDisplayInfoFullInit() {
        let expiry = Date(timeIntervalSince1970: 2000000000)
        let url = URL(string: "https://apps.apple.com/account/subscriptions")!
        let info = SubscriptionDisplayInfo(
            planName: "Yearly Pro",
            status: .active,
            expiresAt: expiry,
            isTrial: false,
            renewsAutomatically: true,
            managementURL: url
        )
        XCTAssertEqual(info.planName, "Yearly Pro")
        XCTAssertEqual(info.status, .active)
        XCTAssertEqual(info.expiresAt, expiry)
        XCTAssertFalse(info.isTrial)
        XCTAssertTrue(info.renewsAutomatically)
        XCTAssertEqual(info.managementURL, url)
    }

    func testSubscriptionDisplayInfoMinimalInit() {
        let info = SubscriptionDisplayInfo(planName: "Free")
        XCTAssertEqual(info.planName, "Free")
        XCTAssertEqual(info.status, .unknown) // default
        XCTAssertNil(info.expiresAt) // default
        XCTAssertFalse(info.isTrial) // default
        XCTAssertTrue(info.renewsAutomatically) // default
        XCTAssertNil(info.managementURL) // default
    }

    func testSubscriptionDisplayInfoTrialState() {
        let info = SubscriptionDisplayInfo(
            planName: "Monthly",
            status: .trial,
            isTrial: true,
            renewsAutomatically: true
        )
        XCTAssertEqual(info.status, .trial)
        XCTAssertTrue(info.isTrial)
    }

    func testSubscriptionDisplayInfoCancelled() {
        let info = SubscriptionDisplayInfo(
            planName: "Yearly",
            status: .cancelled,
            renewsAutomatically: false
        )
        XCTAssertEqual(info.status, .cancelled)
        XCTAssertFalse(info.renewsAutomatically)
    }

    // MARK: - SubscriptionStatus Tests

    func testSubscriptionStatusAllCases() {
        XCTAssertEqual(SubscriptionStatus.active.rawValue, "active")
        XCTAssertEqual(SubscriptionStatus.trial.rawValue, "trial")
        XCTAssertEqual(SubscriptionStatus.expired.rawValue, "expired")
        XCTAssertEqual(SubscriptionStatus.cancelled.rawValue, "cancelled")
        XCTAssertEqual(SubscriptionStatus.free.rawValue, "free")
        XCTAssertEqual(SubscriptionStatus.unknown.rawValue, "unknown")
    }

    func testSubscriptionStatusFromRawValue() {
        XCTAssertEqual(SubscriptionStatus(rawValue: "active"), .active)
        XCTAssertEqual(SubscriptionStatus(rawValue: "trial"), .trial)
        XCTAssertEqual(SubscriptionStatus(rawValue: "expired"), .expired)
        XCTAssertEqual(SubscriptionStatus(rawValue: "cancelled"), .cancelled)
        XCTAssertEqual(SubscriptionStatus(rawValue: "free"), .free)
        XCTAssertEqual(SubscriptionStatus(rawValue: "unknown"), .unknown)
        XCTAssertNil(SubscriptionStatus(rawValue: "bogus"))
    }

    // MARK: - AccountDisplayInfo Tests

    func testAccountDisplayInfoFullInit() {
        let joinDate = Date(timeIntervalSince1970: 1700000000)
        let avatarURL = URL(string: "https://example.com/avatar.png")!
        let info = AccountDisplayInfo(
            displayName: "Paco",
            email: "paco@example.com",
            avatarSystemIcon: "person.crop.circle",
            avatarURL: avatarURL,
            memberSince: joinDate
        )
        XCTAssertEqual(info.displayName, "Paco")
        XCTAssertEqual(info.email, "paco@example.com")
        XCTAssertEqual(info.avatarSystemIcon, "person.crop.circle")
        XCTAssertEqual(info.avatarURL, avatarURL)
        XCTAssertEqual(info.memberSince, joinDate)
    }

    func testAccountDisplayInfoMinimalInit() {
        let info = AccountDisplayInfo(displayName: "Guest")
        XCTAssertEqual(info.displayName, "Guest")
        XCTAssertNil(info.email)
        XCTAssertEqual(info.avatarSystemIcon, "person.circle.fill") // default
        XCTAssertNil(info.avatarURL)
        XCTAssertNil(info.memberSince)
    }

    func testAccountDisplayInfoEmailOnly() {
        let info = AccountDisplayInfo(displayName: "User", email: "user@test.com")
        XCTAssertEqual(info.email, "user@test.com")
        XCTAssertEqual(info.avatarSystemIcon, "person.circle.fill")
    }

    // MARK: - DonkeyDateFormatter Tests

    func testDateFormatterShortStyle() {
        let date = makeDate(year: 2025, month: 3, day: 22)
        let result = DonkeyDateFormatter.format(date, style: .short)
        XCTAssertEqual(result, "Mar 22")
    }

    func testDateFormatterMemberSince() {
        let date = makeDate(year: 2024, month: 6, day: 1)
        let result = DonkeyDateFormatter.format(date, style: .memberSince)
        XCTAssertEqual(result, "Member since June 2024")
    }

    func testDateFormatterExpiresOn() {
        let date = makeDate(year: 2026, month: 12, day: 25)
        let result = DonkeyDateFormatter.format(date, style: .expiresOn)
        // .long dateStyle uses locale-dependent format, but should contain key parts
        XCTAssertTrue(result.hasPrefix("Expires "))
        XCTAssertTrue(result.contains("December"))
        XCTAssertTrue(result.contains("25"))
        XCTAssertTrue(result.contains("2026"))
    }

    func testDateFormatterMediumStyle() {
        let date = makeDate(year: 2025, month: 1, day: 15)
        let result = DonkeyDateFormatter.format(date, style: .medium)
        // .long dateStyle: "January 15, 2025"
        XCTAssertTrue(result.contains("January"))
        XCTAssertTrue(result.contains("15"))
        XCTAssertTrue(result.contains("2025"))
    }

    func testDateFormatterLongStyle() {
        let date = makeDate(year: 2025, month: 6, day: 15)
        let result = DonkeyDateFormatter.format(date, style: .long)
        // .full dateStyle includes day of week
        XCTAssertTrue(result.contains("June"))
        XCTAssertTrue(result.contains("15"))
        XCTAssertTrue(result.contains("2025"))
        XCTAssertTrue(result.contains("Sunday"))
    }

    func testRelativeStringJustNow() {
        let result = DonkeyDateFormatter.relativeString(from: Date())
        XCTAssertEqual(result, "Just now")
    }

    func testRelativeStringFutureDate() {
        let future = Date().addingTimeInterval(3600)
        let result = DonkeyDateFormatter.relativeString(from: future)
        XCTAssertEqual(result, "Just now") // future dates return "Just now"
    }

    func testRelativeStringMinutesAgo() {
        let date = Date().addingTimeInterval(-300) // 5 min ago
        let result = DonkeyDateFormatter.relativeString(from: date)
        XCTAssertEqual(result, "5m ago")
    }

    func testRelativeStringHoursAgo() {
        let date = Date().addingTimeInterval(-7200) // 2 hours ago
        let result = DonkeyDateFormatter.relativeString(from: date)
        XCTAssertEqual(result, "2h ago")
    }

    func testRelativeStringYesterday() {
        let date = Date().addingTimeInterval(-86400) // ~24h ago
        let result = DonkeyDateFormatter.relativeString(from: date)
        XCTAssertEqual(result, "Yesterday")
    }

    func testRelativeStringDaysAgo() {
        let date = Date().addingTimeInterval(-259200) // 3 days ago
        let result = DonkeyDateFormatter.relativeString(from: date)
        XCTAssertEqual(result, "3 days ago")
    }

    func testRelativeStringOlderThan7Days() {
        let date = Date().addingTimeInterval(-864000) // 10 days ago
        let result = DonkeyDateFormatter.relativeString(from: date)
        // Should show "MMM d" format, not relative
        XCTAssertFalse(result.contains("ago"))
        XCTAssertFalse(result.contains("Yesterday"))
        XCTAssertFalse(result.contains("Just now"))
    }

    func testDateFormatterRelativeStyleUsesRelativeString() {
        let result = DonkeyDateFormatter.format(Date(), style: .relative)
        XCTAssertEqual(result, "Just now")
    }

    // MARK: - EmailValidator Tests

    func testEmailValidatorValidEmails() {
        let validEmails = [
            "user@example.com",
            "test@sub.domain.com",
            "hello+tag@gmail.com",
            "name.surname@company.co.uk",
            "a@b.cd",
        ]
        for email in validEmails {
            XCTAssertTrue(EmailValidator.isValid(email), "Expected '\(email)' to be valid")
        }
    }

    func testEmailValidatorInvalidEmails() {
        let invalidEmails = [
            "",                       // empty
            "a",                      // too short
            "a@b",                    // no dot in domain
            "@example.com",           // no local part (< 5 chars anyway)
            "user@",                  // no domain
            "user@.com",              // domain starts with dot
            "user@com.",              // domain ends with dot
            "user @example.com",      // whitespace
            "user@@example.com",      // double @
            "user@exam..ple.com",     // consecutive dots
            "user@-example.com",      // domain starts with hyphen
            "user@example.c",         // TLD too short
            String(repeating: "a", count: 65) + "@example.com", // local too long
        ]
        for email in invalidEmails {
            XCTAssertFalse(EmailValidator.isValid(email), "Expected '\(email)' to be invalid")
        }
    }

    func testEmailValidatorTrimsWhitespace() {
        // The validator trims whitespace, but the trimmed result still must pass all checks
        XCTAssertTrue(EmailValidator.isValid("  user@example.com  "))
    }

    func testEmailValidatorMaxLength() {
        let longLocal = String(repeating: "a", count: 64)
        let longEmail = "\(longLocal)@example.com" // 64 + 1 + 11 = 76 chars, valid
        XCTAssertTrue(EmailValidator.isValid(longEmail))

        let tooLong = String(repeating: "a", count: 64) + "@" + String(repeating: "b", count: 186) + ".com"
        // > 254 chars
        XCTAssertFalse(EmailValidator.isValid(tooLong))
    }

    func testEmailSanitize() {
        XCTAssertEqual(EmailValidator.sanitize("  User@Example.COM  "), "user@example.com")
    }

    func testEmailSanitizeTrimsTabs() {
        XCTAssertEqual(EmailValidator.sanitize("\tuser@test.com\n"), "user@test.com")
    }

    func testEmailSanitizeAlreadyClean() {
        XCTAssertEqual(EmailValidator.sanitize("hello@world.com"), "hello@world.com")
    }

    func testEmailSanitizeEmpty() {
        XCTAssertEqual(EmailValidator.sanitize(""), "")
    }

    // MARK: - DonkeyCurrencyFormatter Tests

    func testCurrencyFormatUSD() {
        let result = DonkeyCurrencyFormatter.format(9.99, currencyCode: "USD")
        XCTAssertTrue(result.contains("9.99"), "Expected result to contain '9.99', got: \(result)")
    }

    func testCurrencyFormatZero() {
        let result = DonkeyCurrencyFormatter.format(0, currencyCode: "USD")
        XCTAssertTrue(result.contains("0.00"), "Expected result to contain '0.00', got: \(result)")
    }

    func testCurrencyFormatLargeAmount() {
        let result = DonkeyCurrencyFormatter.format(1234.56, currencyCode: "USD")
        XCTAssertTrue(result.contains("1,234.56") || result.contains("1234.56"),
                       "Expected formatted large amount, got: \(result)")
    }

    func testCurrencyFormatEUR() {
        let result = DonkeyCurrencyFormatter.format(19.99, currencyCode: "EUR")
        XCTAssertTrue(result.contains("19.99"), "Expected result to contain '19.99', got: \(result)")
    }

    func testCurrencyFormatDefaultCurrency() {
        // Default should be USD
        let result = DonkeyCurrencyFormatter.format(5.0)
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains("5.00"), "Expected result to contain '5.00', got: \(result)")
    }

    func testCurrencyFormatCentsBasic() {
        let result = DonkeyCurrencyFormatter.formatCents(999, currencyCode: "USD")
        XCTAssertTrue(result.contains("9.99"), "Expected result to contain '9.99', got: \(result)")
    }

    func testCurrencyFormatCentsZero() {
        let result = DonkeyCurrencyFormatter.formatCents(0, currencyCode: "USD")
        XCTAssertTrue(result.contains("0.00"), "Expected result to contain '0.00', got: \(result)")
    }

    func testCurrencyFormatCentsSmallAmount() {
        let result = DonkeyCurrencyFormatter.formatCents(1, currencyCode: "USD")
        XCTAssertTrue(result.contains("0.01"), "Expected result to contain '0.01', got: \(result)")
    }

    func testCurrencyFormatCentsLargeAmount() {
        let result = DonkeyCurrencyFormatter.formatCents(123456, currencyCode: "USD")
        XCTAssertTrue(result.contains("1,234.56") || result.contains("1234.56"),
                       "Expected formatted large cents amount, got: \(result)")
    }

    func testCurrencyFormatCentsDefaultCurrency() {
        let result = DonkeyCurrencyFormatter.formatCents(500)
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains("5.00"), "Expected result to contain '5.00', got: \(result)")
    }

    func testCurrencyFormatNegativeAmount() {
        let result = DonkeyCurrencyFormatter.format(-9.99, currencyCode: "USD")
        XCTAssertTrue(result.contains("9.99"), "Expected result to contain '9.99', got: \(result)")
    }

    // MARK: - DonkeyDateStyle Enum Tests

    func testDonkeyDateStyleAllCases() {
        // Verify all enum cases exist by exhaustive switch
        let styles: [DonkeyDateStyle] = [.relative, .short, .medium, .long, .memberSince, .expiresOn]
        XCTAssertEqual(styles.count, 6)
    }

    // MARK: - Helpers

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = 0
        components.timeZone = Calendar.current.timeZone
        return Calendar.current.date(from: components)!
    }
}
