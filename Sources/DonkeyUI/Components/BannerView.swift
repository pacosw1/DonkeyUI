import SwiftUI

// MARK: - BannerType

public enum BannerType {
    case info
    case success
    case warning
    case error
    case promo

    public var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.octagon.fill"
        case .promo: return "gift.fill"
        }
    }

    public func foregroundColor(from theme: DonkeyTheme) -> Color {
        switch self {
        case .info: return theme.colors.primary
        case .success: return theme.colors.success
        case .warning: return theme.colors.warning
        case .error: return theme.colors.error
        case .promo: return .purple
        }
    }

    public func backgroundColor(from theme: DonkeyTheme) -> Color {
        foregroundColor(from: theme).opacity(0.1)
    }

    public func borderColor(from theme: DonkeyTheme) -> Color {
        foregroundColor(from: theme).opacity(0.25)
    }
}

// MARK: - BannerView

public struct BannerView: View {
    var type: BannerType
    var message: String
    var actionLabel: String?
    var onAction: (() -> Void)?
    var onDismiss: (() -> Void)?

    @Environment(\.donkeyTheme) var theme

    public init(
        type: BannerType,
        message: String,
        actionLabel: String? = nil,
        onAction: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.type = type
        self.message = message
        self.actionLabel = actionLabel
        self.onAction = onAction
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: theme.spacing.md) {
            Image(systemName: type.icon)
                .font(theme.typography.body)
                .foregroundColor(type.foregroundColor(from: theme))

            Text(message)
                .font(theme.typography.subheadline)
                .fontWeight(theme.typography.defaultWeight)
                .foregroundColor(theme.colors.onSurface)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            if let actionLabel = actionLabel, let onAction = onAction {
                Button(action: onAction) {
                    Text(actionLabel)
                        .font(theme.typography.subheadline)
                        .fontWeight(theme.typography.emphasisWeight)
                        .foregroundColor(type.foregroundColor(from: theme))
                }
                .buttonStyle(.plain)
            }

            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.secondary)
                        .padding(theme.spacing.xs)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, theme.spacing.md)
        .padding(.horizontal, theme.spacing.lg)
        .bgOverlay(
            bgColor: type.backgroundColor(from: theme),
            radius: theme.shape.radiusMedium,
            borderColor: type.borderColor(from: theme),
            borderWidth: 1
        )
    }
}

// MARK: - Preview

struct BannerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            BannerView(
                type: .info,
                message: "A new update is available for your app.",
                actionLabel: "Update",
                onAction: {},
                onDismiss: {}
            )

            BannerView(
                type: .success,
                message: "Your profile has been updated successfully.",
                onDismiss: {}
            )

            BannerView(
                type: .warning,
                message: "Your subscription expires in 3 days.",
                actionLabel: "Renew",
                onAction: {}
            )

            BannerView(
                type: .error,
                message: "Unable to connect to the server. Please try again.",
                onDismiss: {}
            )

            BannerView(
                type: .promo,
                message: "Get 50% off annual plans this week!",
                actionLabel: "Claim",
                onAction: {},
                onDismiss: {}
            )
        }
        .padding()
    }
}
