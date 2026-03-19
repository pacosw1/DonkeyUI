import SwiftUI

// MARK: - FeatureGrid

public struct FeatureGrid: View {
    let features: [PaywallFeatureItem]
    let columns: Int

    @Environment(\.donkeyTheme) var theme

    public init(
        features: [PaywallFeatureItem],
        columns: Int = 1
    ) {
        self.features = features
        self.columns = max(1, columns)
    }

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: theme.spacing.md), count: columns)
    }

    public var body: some View {
        LazyVGrid(columns: gridColumns, alignment: .leading, spacing: theme.spacing.lg) {
            ForEach(features) { feature in
                switch feature.icon {
                case .system:
                    symbolRow(feature)
                case .emoji:
                    emojiRow(feature)
                }
            }
        }
    }

    // MARK: - SF Symbol Row (icon + title + description)

    private func symbolRow(_ feature: PaywallFeatureItem) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.md) {
            if case .system(let name) = feature.icon {
                Image(systemName: name)
                    .font(theme.typography.body)
                    .fontWeight(theme.typography.emphasisWeight)
                    .foregroundColor(feature.iconColor)
                    .frame(width: 36, height: 36)
                    .bgOverlay(
                        bgColor: feature.iconColor.opacity(0.12),
                        radius: theme.shape.radiusSmall
                    )
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(feature.title)
                    .font(theme.typography.subheadline)
                    .fontWeight(theme.typography.emphasisWeight)
                    .foregroundColor(theme.colors.onSurface)

                if !feature.description.isEmpty {
                    Text(feature.description)
                        .font(theme.typography.footnote)
                        .foregroundColor(theme.colors.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: - Emoji Row (emoji circle + text with optional bold word)

    private func emojiRow(_ feature: PaywallFeatureItem) -> some View {
        HStack(alignment: .center, spacing: theme.spacing.md) {
            if case .emoji(let emoji) = feature.icon {
                Text(emoji)
                    .font(.system(size: 14))
                    .frame(width: 38, height: 38)
                    .background {
                        Circle()
                            .fill(feature.iconColor.opacity(0.3))
                    }
            }

            emojiText(feature)
                .font(.system(size: 13))
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .bgOverlay(
                    bgColor: theme.colors.surface,
                    radius: theme.shape.radiusMedium,
                    borderColor: theme.colors.borderSubtle,
                    borderWidth: 1
                )
        }
    }

    @ViewBuilder
    private func emojiText(_ feature: PaywallFeatureItem) -> some View {
        if feature.boldWord.isEmpty {
            Text(feature.title)
                .foregroundStyle(theme.colors.onSurface)
        } else {
            Text("\(Text(feature.boldWord).foregroundStyle(theme.colors.accent).fontWeight(.bold)) \(feature.title)")
                .foregroundStyle(theme.colors.onSurface)
        }
    }
}

// MARK: - Preview

struct FeatureGrid_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("SF Symbol Features").font(.headline)
                FeatureGrid(features: [
                    PaywallFeatureItem(systemIcon: "chart.bar.fill", iconColor: .blue, title: "Analytics", description: "Track your progress"),
                    PaywallFeatureItem(systemIcon: "icloud.fill", iconColor: .cyan, title: "Cloud Sync", description: "Access anywhere"),
                    PaywallFeatureItem(systemIcon: "bell.badge.fill", iconColor: .orange, title: "Reminders", description: "Never miss a task"),
                ])

                Divider()

                Text("Emoji Features").font(.headline)
                FeatureGrid(features: [
                    PaywallFeatureItem(emoji: "🏋️", color: Color.green.opacity(0.6), text: "habits", boldWord: "Unlimited"),
                    PaywallFeatureItem(emoji: "📲", color: Color.blue.opacity(0.6), text: "Homescreen", boldWord: "Widgets"),
                    PaywallFeatureItem(emoji: "📅", color: Color.red.opacity(0.6), text: "Edit Habit History"),
                    PaywallFeatureItem(emoji: "❤️", color: Color.pink.opacity(0.6), text: "Support an Independent Developer"),
                    PaywallFeatureItem(emoji: "☁️", color: Color.gray.opacity(0.6), text: "Cloud Sync"),
                ])
                .padding(.horizontal, 20)
            }
            .padding()
        }
    }
}
