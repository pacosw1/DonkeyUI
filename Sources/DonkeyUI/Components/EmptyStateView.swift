import SwiftUI

// MARK: - EmptyStateView

public struct EmptyStateView: View {
    let systemIcon: String
    let title: String
    let description: String?
    let ctaLabel: String?
    let ctaAction: (() -> Void)?

    @Environment(\.donkeyTheme) var theme

    public init(
        systemIcon: String,
        title: String,
        description: String? = nil,
        ctaLabel: String? = nil,
        ctaAction: (() -> Void)? = nil
    ) {
        self.systemIcon = systemIcon
        self.title = title
        self.description = description
        self.ctaLabel = ctaLabel
        self.ctaAction = ctaAction
    }

    public var body: some View {
        VStack(spacing: theme.spacing.lg) {
            Image(systemName: systemIcon)
                .font(.system(size: 48))
                .fontWeight(.light)
                .foregroundColor(theme.colors.secondary.opacity(0.6))
                .frame(width: 88, height: 88)
                .bgOverlay(
                    bgColor: theme.colors.secondary.opacity(0.08),
                    radius: theme.shape.radiusXL
                )

            VStack(spacing: theme.spacing.sm) {
                Text(title)
                    .font(theme.typography.title3)
                    .fontWeight(theme.typography.emphasisWeight)
                    .foregroundColor(theme.colors.onBackground)
                    .multilineTextAlignment(.center)

                if let description = description {
                    Text(description)
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, theme.spacing.xxl)

            if let label = ctaLabel, let action = ctaAction {
                ThemedButton(label, role: .primary, action: action)
                    .padding(.top, theme.spacing.xs)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacing.xxxl)
    }
}

// MARK: - Preview

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            EmptyStateView(
                systemIcon: "tray",
                title: "No Items Yet",
                description: "Start by adding your first item to get going.",
                ctaLabel: "Add Item",
                ctaAction: {}
            )

            Divider()

            EmptyStateView(
                systemIcon: "magnifyingglass",
                title: "No Results",
                description: "Try adjusting your search or filters."
            )
        }
    }
}
