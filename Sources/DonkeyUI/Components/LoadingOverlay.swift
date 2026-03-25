import SwiftUI

// MARK: - LoadingOverlay

public struct LoadingOverlay: View {
    @Binding var isPresented: Bool
    let message: String?

    @Environment(\.donkeyTheme) var theme

    public init(
        isPresented: Binding<Bool>,
        message: String? = nil
    ) {
        self._isPresented = isPresented
        self.message = message
    }

    public var body: some View {
        ZStack {
            if isPresented {
                // Dimmed backdrop
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)

                // Loading card
                VStack(spacing: theme.spacing.lg) {
                    SpinnerLoadingView(
                        color: theme.colors.primary,
                        size: 36,
                        lineWidth: 4
                    )

                    if let message = message {
                        Text(message)
                            .font(theme.typography.callout)
                            .fontWeight(theme.typography.emphasisWeight)
                            .foregroundStyle(theme.colors.onSurface)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                }
                .padding(theme.spacing.xl)
                .frame(minWidth: 140)
                .bgOverlay(
                    bgColor: theme.colors.surface,
                    radius: theme.shape.radiusLarge
                )
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 8)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
        .allowsHitTesting(isPresented)
    }
}

// MARK: - View Modifier

public struct LoadingOverlayModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String?

    public func body(content: Content) -> some View {
        content
            .overlay {
                LoadingOverlay(isPresented: $isPresented, message: message)
            }
    }
}

public extension View {
    func loadingOverlay(isPresented: Binding<Bool>, message: String? = nil) -> some View {
        modifier(LoadingOverlayModifier(isPresented: isPresented, message: message))
    }
}

// MARK: - Preview

struct LoadingOverlay_Previews: PreviewProvider {
    struct Demo: View {
        @State private var isLoading = true
        @State private var isPurchasing = false
        @State private var isUploading = false

        var body: some View {
            VStack(spacing: 20) {
                Text("Main Content")
                    .font(.largeTitle)

                Button("Toggle Loading") {
                    isLoading.toggle()
                }

                Button("Simulate Purchase") {
                    isPurchasing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isPurchasing = false
                    }
                }

                Button("Simulate Upload") {
                    isUploading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isUploading = false
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .loadingOverlay(isPresented: $isLoading)
            .loadingOverlay(isPresented: $isPurchasing, message: "Completing Purchase...")
            .loadingOverlay(isPresented: $isUploading, message: "Uploading your photo\nPlease wait")
        }
    }

    static var previews: some View {
        Demo()
    }
}
