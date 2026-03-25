#if os(watchOS)
import SwiftUI

// MARK: - WatchConfirmation

public struct WatchConfirmation: View {
    @Binding var isPresented: Bool
    let message: String
    let confirmLabel: String
    let cancelLabel: String
    let isDestructive: Bool
    let onConfirm: () -> Void

    @Environment(\.donkeyTheme) var theme

    public init(
        isPresented: Binding<Bool>,
        message: String,
        confirmLabel: String = "Confirm",
        cancelLabel: String = "Cancel",
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self.message = message
        self.confirmLabel = confirmLabel
        self.cancelLabel = cancelLabel
        self.isDestructive = isDestructive
        self.onConfirm = onConfirm
    }

    public var body: some View {
        if isPresented {
            VStack(spacing: theme.spacing.lg) {
                Text(message)
                    .font(theme.typography.headline)
                    .fontWeight(theme.typography.emphasisWeight)
                    .foregroundColor(theme.colors.onBackground)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: {
                    DonkeyHaptics.medium()
                    onConfirm()
                    isPresented = false
                }) {
                    Text(confirmLabel)
                        .font(theme.typography.body)
                        .fontWeight(theme.typography.emphasisWeight)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(isDestructive ? theme.colors.destructive : theme.colors.primary)
                .controlSize(.large)

                Button(action: {
                    DonkeyHaptics.light()
                    isPresented = false
                }) {
                    Text(cancelLabel)
                        .font(theme.typography.body)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(theme.spacing.md)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.colors.background.ignoresSafeArea())
        }
    }
}

// MARK: - View Modifier

public struct WatchConfirmationModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let confirmLabel: String
    let cancelLabel: String
    let isDestructive: Bool
    let onConfirm: () -> Void

    public func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                WatchConfirmation(
                    isPresented: $isPresented,
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
    func watchConfirmation(
        isPresented: Binding<Bool>,
        message: String,
        confirmLabel: String = "Confirm",
        cancelLabel: String = "Cancel",
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(WatchConfirmationModifier(
            isPresented: isPresented,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            isDestructive: isDestructive,
            onConfirm: onConfirm
        ))
    }
}

// MARK: - Preview

struct WatchConfirmation_Previews: PreviewProvider {
    struct Demo: View {
        @State private var showConfirm = true

        var body: some View {
            Button("Delete") { showConfirm = true }
                .watchConfirmation(
                    isPresented: $showConfirm,
                    message: "Delete this item?",
                    confirmLabel: "Delete",
                    isDestructive: true,
                    onConfirm: {}
                )
        }
    }

    static var previews: some View {
        Demo()
    }
}
#endif
