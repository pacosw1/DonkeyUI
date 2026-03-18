import SwiftUI

// MARK: - SubscriptionCard

public struct SubscriptionCard: View {
    let subscription: SubscriptionDisplayInfo
    let onUpgrade: (() -> Void)?
    let onManage: (() -> Void)?

    @Environment(\.donkeyTheme) var theme

    public init(
        subscription: SubscriptionDisplayInfo,
        onUpgrade: (() -> Void)? = nil,
        onManage: (() -> Void)? = nil
    ) {
        self.subscription = subscription
        self.onUpgrade = onUpgrade
        self.onManage = onManage
    }

    public var body: some View {
        ThemedCard(variant: .outlined) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                        Text(subscription.planName)
                            .font(theme.typography.title3)
                            .fontWeight(theme.typography.heavyWeight)
                            .foregroundColor(theme.colors.onSurface)

                        statusRow
                    }

                    Spacer()

                    statusBadge
                }

                if let expiresAt = subscription.expiresAt {
                    HStack(spacing: theme.spacing.xs) {
                        Image(systemName: expiryIcon)
                            .font(theme.typography.caption)
                            .foregroundColor(expiryColor)

                        Text(DonkeyDateFormatter.format(expiresAt, style: .expiresOn))
                            .font(theme.typography.footnote)
                            .foregroundColor(theme.colors.secondary)
                    }
                }

                if let action = resolvedAction {
                    ThemedButton(
                        action.label,
                        icon: action.icon,
                        role: action.role,
                        fullWidth: true,
                        action: action.handler
                    )
                }
            }
        }
    }

    // MARK: - Status Row

    private var statusRow: some View {
        HStack(spacing: theme.spacing.xs) {
            if subscription.renewsAutomatically && subscription.status == .active {
                Text("Auto-renews")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.secondary)
            } else if subscription.isTrial {
                Text("Free trial")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.primary)
            }
        }
    }

    // MARK: - Badge

    private var statusBadge: some View {
        Text(statusLabel)
            .font(theme.typography.caption)
            .fontWeight(theme.typography.emphasisWeight)
            .foregroundColor(.white)
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .bgOverlay(bgColor: statusColor, radius: theme.shape.radiusFull)
    }

    private var statusLabel: String {
        switch subscription.status {
        case .active: return "Active"
        case .trial: return "Trial"
        case .expired: return "Expired"
        case .cancelled: return "Cancelled"
        case .free: return "Free"
        case .unknown: return "Unknown"
        }
    }

    private var statusColor: Color {
        switch subscription.status {
        case .active: return theme.colors.success
        case .trial: return theme.colors.primary
        case .expired: return theme.colors.error
        case .cancelled: return theme.colors.warning
        case .free: return theme.colors.secondary
        case .unknown: return theme.colors.secondary
        }
    }

    // MARK: - Expiry

    private var expiryIcon: String {
        switch subscription.status {
        case .expired, .cancelled: return "exclamationmark.circle"
        default: return "calendar"
        }
    }

    private var expiryColor: Color {
        switch subscription.status {
        case .expired: return theme.colors.error
        case .cancelled: return theme.colors.warning
        default: return theme.colors.secondary
        }
    }

    // MARK: - Action

    private struct ResolvedAction {
        let label: String
        let icon: String
        let role: ThemedButtonRole
        let handler: () -> Void
    }

    private var resolvedAction: ResolvedAction? {
        switch subscription.status {
        case .free, .expired, .cancelled:
            guard let onUpgrade = onUpgrade else { return nil }
            return ResolvedAction(
                label: "Upgrade",
                icon: "arrow.up.circle",
                role: .primary,
                handler: onUpgrade
            )

        case .active, .trial:
            guard let onManage = onManage else { return nil }
            return ResolvedAction(
                label: "Manage Subscription",
                icon: "gear",
                role: .secondary,
                handler: onManage
            )

        case .unknown:
            return nil
        }
    }
}

// MARK: - Preview

struct SubscriptionCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            SubscriptionCard(
                subscription: SubscriptionDisplayInfo(
                    planName: "Pro Monthly",
                    status: .active,
                    expiresAt: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
                    renewsAutomatically: true
                ),
                onManage: {}
            )

            SubscriptionCard(
                subscription: SubscriptionDisplayInfo(
                    planName: "Free Plan",
                    status: .free
                ),
                onUpgrade: {}
            )

            SubscriptionCard(
                subscription: SubscriptionDisplayInfo(
                    planName: "Pro Annual",
                    status: .expired,
                    expiresAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())
                ),
                onUpgrade: {}
            )
        }
        .padding()
    }
}
