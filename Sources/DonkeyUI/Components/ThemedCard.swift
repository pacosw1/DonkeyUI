import SwiftUI

// MARK: - CardVariant

public enum CardVariant {
    case elevated
    case outlined
    case filled(Color)
}

// MARK: - ThemedCard

public struct ThemedCard<Content: View>: View {
    let variant: CardVariant
    let padding: CGFloat?
    @ViewBuilder let content: () -> Content

    @Environment(\.donkeyTheme) var theme

    public init(
        variant: CardVariant = .elevated,
        padding: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.variant = variant
        self.padding = padding
        self.content = content
    }

    private var resolvedPadding: CGFloat {
        padding ?? theme.spacing.lg
    }

    private var backgroundColor: Color {
        switch variant {
        case .elevated:
            return theme.colors.surface
        case .outlined:
            return .clear
        case .filled(let color):
            return color
        }
    }

    private var borderColor: Color {
        switch variant {
        case .elevated:
            return .clear
        case .outlined:
            return theme.colors.border
        case .filled:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch variant {
        case .outlined:
            return 1
        default:
            return 0
        }
    }

    public var body: some View {
        content()
            .padding(resolvedPadding)
            .bgOverlay(
                bgColor: backgroundColor,
                radius: theme.shape.radiusMedium,
                borderColor: borderColor,
                borderWidth: borderWidth
            )
            .shadow(
                color: variant.isElevated ? Color.black.opacity(0.08) : .clear,
                radius: variant.isElevated ? 8 : 0,
                x: 0,
                y: variant.isElevated ? 2 : 0
            )
    }
}

// MARK: - CardVariant Helpers

extension CardVariant {
    var isElevated: Bool {
        if case .elevated = self { return true }
        return false
    }
}

// MARK: - Preview

struct ThemedCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ThemedCard(variant: .elevated) {
                Text("Elevated Card")
            }

            ThemedCard(variant: .outlined) {
                Text("Outlined Card")
            }

            ThemedCard(variant: .filled(.blue.opacity(0.1))) {
                Text("Filled Card")
            }
        }
        .padding()
    }
}
