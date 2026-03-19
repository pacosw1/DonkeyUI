//
//  GridModel.swift
//  DonkeyUI
//
//  GitHub-style contribution grid model.
//  Calculates date layout for a configurable number of days and rows.
//

import Foundation

/// Model that computes the date grid layout for ``ActivityGridView``.
///
/// Given a reference date, total number of days, and row count, this model
/// determines the start date and column count so the grid aligns to week
/// boundaries (Sunday = column start).
public struct ActivityGridModel: Equatable, Sendable {

    // MARK: - Properties

    public let startDate: Date
    public let totalDays: Int
    public let rows: Int
    public private(set) var columns: Int = 0

    private static let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1 // Sunday
        return cal
    }()

    // MARK: - Init

    /// Creates a grid model.
    /// - Parameters:
    ///   - currentDate: The reference "today" date (right edge of the grid).
    ///   - totalDays: How many days of history to display.
    ///   - rows: Number of rows (typically 7 for a full week).
    public init(currentDate: Date, totalDays: Int, rows: Int = 7) {
        let cal = Self.calendar
        let date = Self.computeStartDate(date: currentDate, totalDays: totalDays, rows: rows, calendar: cal)
        self.totalDays = totalDays
        self.startDate = date
        self.rows = rows
        self.columns = Self.computeColumns(startDate: date, currentDate: currentDate, totalDays: totalDays, rows: rows, calendar: cal)
    }

    // MARK: - Public API

    /// Returns the date for the given grid position.
    /// - Parameters:
    ///   - rowIndex: Row index (0 = Sunday when rows == 7).
    ///   - columnIndex: Column index (0 = earliest week).
    /// - Returns: The ``Date`` at start-of-day for that cell.
    public func dateForIndexes(rowIndex: Int, columnIndex: Int) -> Date {
        let cal = Self.calendar
        let dayOffset = (rows * columnIndex) + rowIndex
        return cal.date(byAdding: .day, value: dayOffset, to: startDate)
            .map { cal.startOfDay(for: $0) } ?? startDate
    }

    // MARK: - Private Helpers

    private static func computeStartDate(date: Date, totalDays: Int, rows: Int, calendar: Calendar) -> Date {
        let startOfToday = calendar.startOfDay(for: date)
        guard let originalDate = calendar.date(byAdding: .day, value: -totalDays, to: startOfToday) else {
            return startOfToday
        }
        let dayOfWeek = calendar.component(.weekday, from: originalDate)
        let goForward = rows - dayOfWeek < dayOfWeek
        let increment = goForward ? 1 : -1
        var newDate = originalDate
        while calendar.component(.weekday, from: newDate) != 1 { // 1 = Sunday
            guard let next = calendar.date(byAdding: .day, value: increment, to: newDate) else { break }
            newDate = next
        }
        return calendar.startOfDay(for: newDate)
    }

    private static func computeColumns(startDate: Date, currentDate: Date, totalDays: Int, rows: Int, calendar: Calendar) -> Int {
        let columns = Int(ceil(Double(totalDays) / Double(rows)))

        // Check if the last cell date is within the same week as currentDate
        let dayOffset = (rows - 1) + (rows * (columns - 1))
        guard let lastDate = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else {
            return columns
        }
        let lastDateStart = calendar.startOfDay(for: lastDate)
        let currentStart = calendar.startOfDay(for: currentDate)
        let sameWeek = calendar.isDate(lastDateStart, equalTo: currentStart, toGranularity: .weekOfYear)
        return columns + (sameWeek ? 0 : 1)
    }
}
