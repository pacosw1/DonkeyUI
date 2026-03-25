import SwiftUI

// MARK: - ChangelogEntry

public struct ChangelogEntry: Identifiable {
    public let id: String
    public let version: String
    public let date: Date
    public let changes: [String]

    public init(
        id: String = UUID().uuidString,
        version: String,
        date: Date,
        changes: [String]
    ) {
        self.id = id
        self.version = version
        self.date = date
        self.changes = changes
    }
}

// MARK: - ChangelogView

public struct ChangelogView: View {
    let entries: [ChangelogEntry]

    @Environment(\.donkeyTheme) var theme

    public init(entries: [ChangelogEntry]) {
        self.entries = entries
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.xl) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    entryCard(entry, isLatest: index == 0)
                }
            }
            .padding(theme.spacing.lg)
        }
    }

    private func entryCard(_ entry: ChangelogEntry, isLatest: Bool) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                Text("v\(entry.version)")
                    .font(theme.typography.title3)
                    .fontWeight(theme.typography.heavyWeight)
                    .foregroundStyle(theme.colors.onSurface)

                if isLatest {
                    Text("Latest")
                        .font(theme.typography.caption2)
                        .fontWeight(theme.typography.emphasisWeight)
                        .foregroundStyle(theme.colors.onPrimary)
                        .padding(.horizontal, theme.spacing.sm)
                        .padding(.vertical, theme.spacing.xxs)
                        .bgOverlay(
                            bgColor: theme.colors.primary,
                            radius: theme.shape.radiusFull
                        )
                }

                Spacer()

                Text(formattedDate(entry.date))
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.secondary)
            }

            // Divider
            Rectangle()
                .fill(theme.colors.border)
                .frame(height: 1)

            // Changes
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                ForEach(Array(entry.changes.enumerated()), id: \.offset) { _, change in
                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        Circle()
                            .fill(theme.colors.primary.opacity(0.6))
                            .frame(width: 6, height: 6)
                            .padding(.top, 7)

                        Text(change)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.onSurface)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(theme.spacing.lg)
        .bgOverlay(
            bgColor: theme.colors.surface,
            radius: theme.shape.radiusMedium,
            borderColor: isLatest ? theme.colors.primary.opacity(0.3) : theme.colors.borderSubtle,
            borderWidth: 1
        )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Preview

struct ChangelogView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogView(entries: [
            ChangelogEntry(
                version: "2.4.0",
                date: Date(),
                changes: [
                    "Added dark mode support across all screens",
                    "Improved performance for large datasets",
                    "Fixed crash when deleting items in bulk"
                ]
            ),
            ChangelogEntry(
                version: "2.3.1",
                date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                changes: [
                    "Bug fix: notifications not showing on iOS 17",
                    "Updated app icon"
                ]
            ),
            ChangelogEntry(
                version: "2.3.0",
                date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                changes: [
                    "New widget for home screen",
                    "Redesigned settings page",
                    "Added export to CSV feature",
                    "Performance improvements for charts"
                ]
            ),
            ChangelogEntry(
                version: "2.2.0",
                date: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
                changes: [
                    "Initial release of the redesigned app",
                    "Added iCloud sync"
                ]
            )
        ])
    }
}
