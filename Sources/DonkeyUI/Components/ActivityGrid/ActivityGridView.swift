//
//  ActivityGridView.swift
//  DonkeyUI
//
//  A GitHub-style contribution/activity grid.
//  Displays a heatmap of activity data over time with configurable colors,
//  intensity levels, and scroll behavior.
//

import SwiftUI

/// A GitHub-style contribution grid that visualizes daily activity data as a color-intensity heatmap.
///
/// The grid displays rows (days of the week) and columns (weeks), with each cell colored
/// according to the activity count for that date.
///
/// ```swift
/// ActivityGridView(
///     records: [Date(): 3, Calendar.current.date(byAdding: .day, value: -1, to: Date())!: 1],
///     color: .green,
///     date: Date()
/// )
/// ```
///
/// - Parameters:
///   - dayCount: Total number of days of history to show (default 365).
///   - records: A dictionary mapping dates (start-of-day) to activity counts.
///   - singleIntensity: If `true`, all non-zero cells use the same opacity instead of graduated intensity.
///   - rows: Number of rows in the grid (default 7, one per weekday).
///   - color: The hue used for active cells.
///   - withScroll: If `true`, wraps the grid in a horizontal `ScrollView` with weekday and month labels.
///   - date: The reference "today" date (the grid's right edge).
///   - maxCount: The count at which a cell reaches full intensity (default 1).
public struct ActivityGridView: View, Equatable {

    // MARK: - Equatable

    public static func == (lhs: ActivityGridView, rhs: ActivityGridView) -> Bool {
        lhs.map.hashValue == rhs.map.hashValue
        && lhs.color == rhs.color
        && lhs.withScroll == rhs.withScroll
        && lhs.singleIntensity == rhs.singleIntensity
    }

    // MARK: - Properties

    private let singleIntensity: Bool
    private let model: ActivityGridModel
    private let map: [Date: Int]
    private let color: Color
    private let maxCount: Int
    private let withScroll: Bool
    private let currentDate: Date

    // MARK: - Init

    /// Creates an activity grid view.
    public init(
        dayCount: Int = 365,
        records: [Date: Int],
        singleIntensity: Bool = false,
        rows: Int = 7,
        color: Color = .accentColor,
        withScroll: Bool = true,
        date: Date,
        maxCount: Int = 1
    ) {
        self.singleIntensity = singleIntensity
        self.model = ActivityGridModel(currentDate: date, totalDays: dayCount, rows: rows)
        self.map = records
        self.color = color
        self.withScroll = withScroll
        self.currentDate = date
        self.maxCount = maxCount
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 2) {
            if withScroll {
                weekdayLabelsColumn
                scrollableGrid
            } else {
                compactGrid
            }
        }
    }

    // MARK: - Subviews

    private var weekdayLabelsColumn: some View {
        VStack(spacing: 2) {
            ForEach(0..<model.rows + 1, id: \.self) { index in
                WeekDayCell(weekDay: index)
            }
        }
    }

    private var scrollableGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Grid(horizontalSpacing: 3, verticalSpacing: 3) {
                ForEach(0..<model.rows, id: \.self) { row in
                    GridRow {
                        ForEach(0..<model.columns, id: \.self) { col in
                            let date = model.dateForIndexes(rowIndex: row, columnIndex: col)
                            let count = map[date] ?? 0
                            ContributionCell(
                                date: date,
                                currentDate: currentDate,
                                count: count,
                                singleIntensity: singleIntensity,
                                color: color,
                                maxCount: maxCount
                            )
                        }
                    }
                    if row == model.rows - 1 {
                        GridRow {
                            ForEach(0..<model.columns, id: \.self) { col in
                                let weekStart = model.dateForIndexes(rowIndex: 0, columnIndex: col)
                                let weekEnd = model.dateForIndexes(rowIndex: 6, columnIndex: col)
                                let isStartRow = dateIsInRange(
                                    date: startOfMonth(for: weekEnd),
                                    start: weekStart,
                                    end: weekEnd
                                )
                                MonthStartCell(
                                    month: monthComponent(of: weekEnd),
                                    startOfMonthRow: isStartRow
                                )
                                .offset(x: col == model.columns - 1 ? -5 : 0)
                            }
                        }
                    }
                }
            }
        }
        .defaultScrollAnchor(.trailing)
        .contentMargins(.trailing, 5, for: .scrollContent)
        .contentMargins(.vertical, 1, for: .scrollContent)
    }

    private var compactGrid: some View {
        VStack(spacing: 2) {
            ForEach(0..<model.rows, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<model.columns, id: \.self) { col in
                        let date = model.dateForIndexes(rowIndex: row, columnIndex: col)
                        let count = map[date] ?? 0
                        ContributionCell(
                            date: date,
                            currentDate: currentDate,
                            count: count,
                            singleIntensity: singleIntensity,
                            color: color,
                            maxCount: maxCount
                        )
                    }
                }
            }
        }
    }

    // MARK: - Date Helpers (private, no external dependencies)

    private func monthComponent(of date: Date) -> Int {
        Calendar.current.component(.month, from: date)
    }

    private func startOfMonth(for date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: date)
        return cal.date(from: comps) ?? date
    }

    private func dateIsInRange(date: Date, start: Date, end: Date) -> Bool {
        let cal = Calendar.current
        let d = cal.startOfDay(for: date)
        let s = cal.startOfDay(for: start)
        let e = cal.startOfDay(for: end)
        return d >= s && d <= e
    }
}

// MARK: - Internal Cell Views

private let activityGridMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
private let activityGridWeekdays = ["S", "M", "T", "W", "T", "F", "S", ""]

struct WeekDayCell: View {
    var weekDay: Int

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .aspectRatio(1, contentMode: .fit)
            .foregroundStyle(.clear)
            .background {
                Text(activityGridWeekdays[weekDay])
                    .font(.system(size: 10))
                    .monospaced()
                    .foregroundStyle(.tertiary)
            }
    }
}

struct MonthStartCell: View {
    var month: Int
    var startOfMonthRow: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .aspectRatio(1, contentMode: .fit)
            .foregroundStyle(.clear)
            .background {
                Text(activityGridMonths[month - 1])
                    .font(.system(size: 10))
                    .monospaced()
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.tertiary)
                    .fontWeight(.semibold)
                    .offset(x: 2)
                    .frame(width: 30)
            }
            .opacity(startOfMonthRow ? 1 : 0)
    }
}

struct ContributionCell: View {
    var date: Date
    var currentDate: Date
    var count: Int
    var singleIntensity: Bool = false
    var color: Color
    var maxCount: Int

    @Environment(\.colorScheme) private var colorScheme

    private var isToday: Bool {
        Calendar.current.isDate(currentDate, inSameDayAs: date)
    }

    private var todayBorderColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .foregroundStyle(count == 0 ? .gray.opacity(0.2) : color.opacity(intensityOpacity(for: count)))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .stroke(isToday ? todayBorderColor : .clear, lineWidth: 1.5)
            )
            .animation(.interpolatingSpring, value: count)
    }

    private func intensityOpacity(for count: Int) -> Double {
        if singleIntensity { return 0.9 }
        switch count {
        case 0: return 0.0
        case 1: return 0.5
        case 2: return 0.8
        default: return 1.0
        }
    }
}

// MARK: - Preview

#Preview("Activity Grid - Scrollable") {
    let calendar = Calendar.current
    let today = Date()
    var records: [Date: Int] = [:]
    for i in 0..<365 {
        if let date = calendar.date(byAdding: .day, value: -i, to: today) {
            let startOfDay = calendar.startOfDay(for: date)
            records[startOfDay] = [0, 0, 0, 1, 1, 2, 3].randomElement()!
        }
    }
    return VStack(spacing: 20) {
        ActivityGridView(
            records: records,
            color: .green,
            date: today,
            maxCount: 3
        )
        .padding()

        ActivityGridView(
            dayCount: 90,
            records: records,
            singleIntensity: true,
            color: .blue,
            withScroll: false,
            date: today
        )
        .padding()
    }
}
