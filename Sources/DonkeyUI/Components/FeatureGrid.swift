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
                featureRow(feature)
            }
        }
    }

    private func featureRow(_ feature: PaywallFeatureItem) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.md) {
            Image(systemName: feature.systemIcon)
                .font(theme.typography.body)
                .fontWeight(theme.typography.emphasisWeight)
                .foregroundColor(feature.iconColor)
                .frame(width: 36, height: 36)
                .bgOverlay(
                    bgColor: feature.iconColor.opacity(0.12),
                    radius: theme.shape.radiusSmall
                )

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(feature.title)
                    .font(theme.typography.subheadline)
                    .fontWeight(theme.typography.emphasisWeight)
                    .foregroundColor(theme.colors.onSurface)

                Text(feature.description)
                    .font(theme.typography.footnote)
                    .foregroundColor(theme.colors.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Preview

struct FeatureGrid_Previews: PreviewProvider {
    static let features: [PaywallFeatureItem] = [
        PaywallFeatureItem(
            systemIcon: "chart.bar.fill",
            iconColor: .blue,
            title: "Advanced Analytics",
            description: "Track your progress with detailed charts"
        ),
        PaywallFeatureItem(
            systemIcon: "icloud.fill",
            iconColor: .cyan,
            title: "Cloud Sync",
            description: "Access your data on all devices"
        ),
        PaywallFeatureItem(
            systemIcon: "bell.badge.fill",
            iconColor: .orange,
            title: "Smart Reminders",
            description: "Never miss an important task"
        ),
        PaywallFeatureItem(
            systemIcon: "paintbrush.fill",
            iconColor: .purple,
            title: "Custom Themes",
            description: "Personalize your experience"
        ),
    ]

    static var previews: some View {
        VStack(spacing: 32) {
            Text("Single Column").font(.headline)
            FeatureGrid(features: features, columns: 1)

            Divider()

            Text("Two Columns").font(.headline)
            FeatureGrid(features: features, columns: 2)
        }
        .padding()
    }
}
