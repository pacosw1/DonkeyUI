#if canImport(WidgetKit)
import WidgetKit

/// Static helpers for building widget timelines.
public enum DonkeyTimelineHelper {

    /// Creates a timeline with a single entry that refreshes after the given number of minutes.
    public static func singleEntry<E: TimelineEntry>(
        _ entry: E,
        refreshAfter minutes: Int = 30
    ) -> Timeline<E> {
        let refreshDate = Calendar.current.date(
            byAdding: .minute,
            value: minutes,
            to: entry.date
        ) ?? entry.date.addingTimeInterval(TimeInterval(minutes * 60))

        return Timeline(entries: [entry], policy: .after(refreshDate))
    }

    /// Creates a timeline with multiple entries generated at regular intervals.
    public static func entries<E: TimelineEntry>(
        count: Int = 24,
        interval: TimeInterval = 3600,
        factory: (Date) -> E
    ) -> Timeline<E> {
        let now = Date()
        let entries = (0..<count).map { index in
            let date = now.addingTimeInterval(interval * Double(index))
            return factory(date)
        }
        let refreshDate = now.addingTimeInterval(interval * Double(count))
        return Timeline(entries: entries, policy: .after(refreshDate))
    }
}
#endif
