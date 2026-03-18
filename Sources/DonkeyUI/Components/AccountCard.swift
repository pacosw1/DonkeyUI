import SwiftUI

// MARK: - AccountCard

public struct AccountCard: View {
    let account: AccountDisplayInfo
    let subscription: SubscriptionDisplayInfo?
    let onTap: (() -> Void)?

    @Environment(\.donkeyTheme) var theme

    public init(
        account: AccountDisplayInfo,
        subscription: SubscriptionDisplayInfo? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.account = account
        self.subscription = subscription
        self.onTap = onTap
    }

    public var body: some View {
        let cardContent = ThemedCard(variant: .elevated) {
            HStack(spacing: theme.spacing.md) {
                avatarView

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(account.displayName)
                        .font(theme.typography.headline)
                        .fontWeight(theme.typography.emphasisWeight)
                        .foregroundColor(theme.colors.onSurface)

                    if let email = account.email {
                        Text(email)
                            .font(theme.typography.footnote)
                            .foregroundColor(theme.colors.secondary)
                    }

                    if let memberSince = account.memberSince {
                        Text(DonkeyDateFormatter.format(memberSince, style: .memberSince))
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.secondary.opacity(0.7))
                    }
                }

                Spacer(minLength: 0)

                if let subscription = subscription {
                    statusBadge(for: subscription.status)
                }

                if onTap != nil {
                    Image(systemName: "chevron.right")
                        .font(theme.typography.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.secondary.opacity(0.5))
                }
            }
        }

        if let onTap = onTap {
            Button(action: onTap) {
                cardContent
            }
            .buttonStyle(.plain)
        } else {
            cardContent
        }
    }

    @ViewBuilder
    private var avatarView: some View {
        if let url = account.avatarURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())

                default:
                    fallbackAvatar
                }
            }
        } else {
            fallbackAvatar
        }
    }

    private var fallbackAvatar: some View {
        Image(systemName: account.avatarSystemIcon)
            .font(.system(size: 36))
            .foregroundColor(theme.colors.primary)
            .frame(width: 48, height: 48)
    }

    private func statusBadge(for status: SubscriptionStatus) -> some View {
        Text(statusLabel(for: status))
            .font(theme.typography.caption2)
            .fontWeight(theme.typography.emphasisWeight)
            .foregroundColor(.white)
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .bgOverlay(bgColor: statusColor(for: status), radius: theme.shape.radiusFull)
    }

    private func statusLabel(for status: SubscriptionStatus) -> String {
        switch status {
        case .active: return "Pro"
        case .trial: return "Trial"
        case .expired: return "Expired"
        case .cancelled: return "Cancelled"
        case .free: return "Free"
        case .unknown: return ""
        }
    }

    private func statusColor(for status: SubscriptionStatus) -> Color {
        switch status {
        case .active: return theme.colors.success
        case .trial: return theme.colors.primary
        case .expired: return theme.colors.error
        case .cancelled: return theme.colors.warning
        case .free: return theme.colors.secondary
        case .unknown: return .clear
        }
    }
}

// MARK: - Preview

struct AccountCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            AccountCard(
                account: AccountDisplayInfo(
                    displayName: "Paco Sainz",
                    email: "paco@example.com",
                    memberSince: Calendar.current.date(byAdding: .month, value: -6, to: Date())
                ),
                subscription: SubscriptionDisplayInfo(
                    planName: "Pro",
                    status: .active
                ),
                onTap: {}
            )

            AccountCard(
                account: AccountDisplayInfo(
                    displayName: "Jane Doe",
                    email: "jane@example.com"
                )
            )
        }
        .padding()
    }
}
