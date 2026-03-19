import SwiftUI

// MARK: - ToastType

public enum ToastType {
    case success
    case error
    case warning
    case info

    public var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }

    public func color(from theme: DonkeyTheme) -> Color {
        switch self {
        case .success: return theme.colors.success
        case .error: return theme.colors.error
        case .warning: return theme.colors.warning
        case .info: return theme.colors.primary
        }
    }
}

// MARK: - ToastItem

public struct ToastItem: Identifiable {
    public let id: UUID
    public let type: ToastType
    public let message: String

    public init(
        id: UUID = UUID(),
        type: ToastType,
        message: String
    ) {
        self.id = id
        self.type = type
        self.message = message
    }
}

// MARK: - ToastView

public struct ToastView: View {
    let item: ToastItem

    @Environment(\.donkeyTheme) var theme

    public init(item: ToastItem) {
        self.item = item
    }

    public var body: some View {
        HStack(spacing: theme.spacing.md) {
            Image(systemName: item.type.icon)
                .font(theme.typography.title3)
                .foregroundColor(item.type.color(from: theme))

            Text(item.message)
                .font(theme.typography.subheadline)
                .fontWeight(theme.typography.emphasisWeight)
                .foregroundColor(theme.colors.onSurface)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(.vertical, theme.spacing.md)
        .padding(.horizontal, theme.spacing.lg)
        .bgOverlay(
            bgColor: theme.colors.surfaceElevated,
            radius: theme.shape.radiusMedium,
            borderColor: item.type.color(from: theme).opacity(0.3),
            borderWidth: 1
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
        .padding(.horizontal, theme.spacing.lg)
    }
}

// MARK: - ToastModifier

public struct ToastModifier: ViewModifier {
    @Binding var item: ToastItem?

    public func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let toast = item {
                ToastView(item: toast)
                    .padding(.top, theme.spacing.sm)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        )
                    )
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if item?.id == toast.id {
                                    item = nil
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            item = nil
                        }
                    }
                    .zIndex(999)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: item?.id)
    }

    @Environment(\.donkeyTheme) var theme
}

public extension View {
    func toast(item: Binding<ToastItem?>) -> some View {
        modifier(ToastModifier(item: item))
    }
}

// MARK: - Preview

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ToastView(item: ToastItem(type: .success, message: "Changes saved successfully!"))
            ToastView(item: ToastItem(type: .error, message: "Failed to upload file."))
            ToastView(item: ToastItem(type: .warning, message: "Your subscription expires soon."))
            ToastView(item: ToastItem(type: .info, message: "New version available."))
        }
        .padding(.vertical)
    }
}
