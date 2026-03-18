import SwiftUI

// MARK: - ThemedButtonRole

public enum ThemedButtonRole {
    case primary
    case secondary
    case destructive
}

// MARK: - ThemedButton

public struct ThemedButton: View {
    let label: String
    let icon: String?
    let role: ThemedButtonRole
    let fullWidth: Bool
    let isLoading: Bool
    let disabled: Bool
    let action: () -> Void

    @Environment(\.donkeyTheme) var theme

    public init(
        _ label: String,
        icon: String? = nil,
        role: ThemedButtonRole = .primary,
        fullWidth: Bool = false,
        isLoading: Bool = false,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.role = role
        self.fullWidth = fullWidth
        self.isLoading = isLoading
        self.disabled = disabled
        self.action = action
    }

    private var resolvedColor: Color {
        switch role {
        case .primary:
            return theme.colors.primary
        case .secondary:
            return theme.colors.secondary
        case .destructive:
            return theme.colors.destructive
        }
    }

    private var resolvedButtonType: ButtonType {
        switch role {
        case .primary:
            return .filled
        case .secondary:
            return .bordered
        case .destructive:
            return .filled
        }
    }

    public var body: some View {
        ButtonView(
            label: label,
            icon: icon,
            color: resolvedColor,
            buttonType: resolvedButtonType,
            font: theme.typography.body,
            fontWeight: theme.typography.emphasisWeight,
            fullWidth: fullWidth,
            disabled: disabled,
            radius: theme.shape.radiusMedium,
            isLoading: isLoading,
            action: action
        )
    }
}

// MARK: - Preview

struct ThemedButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ThemedButton("Get Started", icon: "arrow.right", role: .primary, action: {})
            ThemedButton("Learn More", role: .secondary, action: {})
            ThemedButton("Delete Account", icon: "trash", role: .destructive, action: {})
            ThemedButton("Full Width", role: .primary, fullWidth: true, action: {})
            ThemedButton("Loading...", role: .primary, isLoading: true, action: {})
        }
        .padding()
    }
}
