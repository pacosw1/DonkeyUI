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
