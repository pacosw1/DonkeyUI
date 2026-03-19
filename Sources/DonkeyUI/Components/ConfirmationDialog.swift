import SwiftUI

// MARK: - DonkeyConfirmationDialog

public struct DonkeyConfirmationDialog: View {
    @Binding var isPresented: Bool
    let title: String
    let message: String?
    let confirmLabel: String
    let cancelLabel: String
    let isDestructive: Bool
    let onConfirm: () -> Void

    @Environment(\.donkeyTheme) var theme

    public init(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        confirmLabel: String = "Confirm",
        cancelLabel: String = "Cancel",
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.confirmLabel = confirmLabel
        self.cancelLabel = cancelLabel
        self.isDestructive = isDestructive
        self.onConfirm = onConfirm
    }

    public var body: some View {
        ZStack {
            // Dimmed backdrop
            Color.black.opacity(isPresented ? 0.4 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            if isPresented {
                // Dialog card
                VStack(spacing: theme.spacing.xl) {
                    // Icon
                    Image(systemName: isDestructive ? "exclamationmark.triangle.fill" : "questionmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(isDestructive ? theme.colors.destructive : theme.colors.primary)

                    // Text
                    VStack(spacing: theme.spacing.sm) {
                        Text(title)
                            .font(theme.typography.title3)
                            .fontWeight(theme.typography.emphasisWeight)
                            .foregroundColor(theme.colors.onSurface)
                            .multilineTextAlignment(.center)

                        if let message = message {
                            Text(message)
                                .font(theme.typography.body)
                                .foregroundColor(theme.colors.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    // Actions
                    VStack(spacing: theme.spacing.sm) {
                        ThemedButton(confirmLabel, role: isDestructive ? .destructive : .primary, fullWidth: true) {
                            DonkeyHaptics.medium()
                            onConfirm()
                            dismiss()
                        }

                        ThemedButton(cancelLabel, role: .secondary, fullWidth: true) {
                            DonkeyHaptics.light()
                            dismiss()
                        }
                    }
                }
                .padding(theme.spacing.xl)
                .bgOverlay(
                    bgColor: theme.colors.surface,
                    radius: theme.shape.radiusXL
                )
                .shadow(color: Color.black.opacity(0.15), radius: 30, x: 0, y: 10)
                .padding(.horizontal, theme.spacing.xxxl)
                .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isPresented)
    }

    private func dismiss() {
        isPresented = false
    }
}

// MARK: - View Modifier

public struct DonkeyConfirmationModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String?
    let confirmLabel: String
    let cancelLabel: String
    let isDestructive: Bool
    let onConfirm: () -> Void

    public func body(content: Content) -> some View {
        content
            .overlay {
                DonkeyConfirmationDialog(
                    isPresented: $isPresented,
                    title: title,
                    message: message,
                    confirmLabel: confirmLabel,
                    cancelLabel: cancelLabel,
                    isDestructive: isDestructive,
                    onConfirm: onConfirm
                )
            }
    }
}

public extension View {
    func donkeyConfirmation(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        confirmLabel: String = "Confirm",
        cancelLabel: String = "Cancel",
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(DonkeyConfirmationModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            isDestructive: isDestructive,
            onConfirm: onConfirm
        ))
    }
}

// MARK: - Preview

struct DonkeyConfirmationDialog_Previews: PreviewProvider {
    struct Demo: View {
        @State private var showDelete = false
        @State private var showLogout = false

        var body: some View {
            VStack(spacing: 20) {
                Button("Delete Account") { showDelete = true }
                Button("Log Out") { showLogout = true }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .donkeyConfirmation(
                isPresented: $showDelete,
                title: "Delete Account?",
                message: "This action cannot be undone. All your data will be permanently removed.",
                confirmLabel: "Delete",
                cancelLabel: "Keep Account",
                isDestructive: true,
                onConfirm: {}
            )
            .donkeyConfirmation(
                isPresented: $showLogout,
                title: "Log Out?",
                message: "You can sign back in anytime.",
                confirmLabel: "Log Out",
                onConfirm: {}
            )
        }
    }

    static var previews: some View {
        Demo()
    }
}
