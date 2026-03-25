#if os(watchOS)
import SwiftUI

// MARK: - WatchEmptyState

public struct WatchEmptyState: View {
    let systemIcon: String
    let title: String
    let buttonLabel: String?
    let buttonAction: (() -> Void)?

    @Environment(\.donkeyTheme) var theme

    public init(
        systemIcon: String,
        title: String,
        buttonLabel: String? = nil,
        buttonAction: (() -> Void)? = nil
    ) {
        self.systemIcon = systemIcon
        self.title = title
        self.buttonLabel = buttonLabel
        self.buttonAction = buttonAction
    }

    public var body: some View {
        VStack(spacing: theme.spacing.md) {
            Image(systemName: systemIcon)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(theme.colors.secondary.opacity(0.6))

            Text(title)
                .font(theme.typography.headline)
                .fontWeight(theme.typography.emphasisWeight)
                .foregroundStyle(theme.colors.onBackground)
                .multilineTextAlignment(.center)

            if let label = buttonLabel, let action = buttonAction {
                Button(action: action) {
                    Text(label)
                        .font(theme.typography.body)
                        .fontWeight(theme.typography.emphasisWeight)
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.colors.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacing.xl)
    }
}

// MARK: - Preview

struct WatchEmptyState_Previews: PreviewProvider {
    static var previews: some View {
        WatchEmptyState(
            systemIcon: "tray",
            title: "No Items Yet",
            buttonLabel: "Add Item",
            buttonAction: {}
        )
    }
}
#endif
