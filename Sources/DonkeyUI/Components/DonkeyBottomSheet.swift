import SwiftUI

// MARK: - SheetDetent

public enum SheetDetent {
    case medium
    case large

    public var fraction: CGFloat {
        switch self {
        case .medium: return 0.5
        case .large: return 0.9
        }
    }
}

// MARK: - DonkeyBottomSheet

public struct DonkeyBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    var detent: SheetDetent
    @ViewBuilder var content: () -> Content

    @Environment(\.donkeyTheme) var theme
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging: Bool = false

    public init(
        isPresented: Binding<Bool>,
        detent: SheetDetent = .medium,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.detent = detent
        self.content = content
    }

    public var body: some View {
        GeometryReader { geo in
            let sheetHeight = geo.size.height * detent.fraction
            let maxDrag = sheetHeight * 0.4

            ZStack(alignment: .bottom) {
                // Dimmed background
                if isPresented {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismiss()
                        }
                        .transition(.opacity)
                        .zIndex(0)
                }

                // Sheet
                if isPresented {
                    VStack(spacing: 0) {
                        // Drag handle
                        Capsule()
                            .fill(theme.colors.border)
                            .frame(width: 36, height: 5)
                            .padding(.top, theme.spacing.sm)
                            .padding(.bottom, theme.spacing.md)

                        // Content
                        content()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: sheetHeight, alignment: .top)
                    .frame(maxWidth: .infinity)
                    .background(
                        UnevenRoundedRectangle(
                            topLeadingRadius: theme.shape.radiusXL,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: theme.shape.radiusXL
                        )
                        .fill(theme.colors.background)
                        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: -5)
                    )
                    .offset(y: max(0, dragOffset))
                    .gesture(
                        DragGesture()
                            .updating($isDragging) { _, state, _ in
                                state = true
                            }
                            .onChanged { value in
                                let translation = value.translation.height
                                if translation > 0 {
                                    dragOffset = translation
                                } else {
                                    // Rubber band effect when dragging up
                                    dragOffset = translation * 0.2
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > maxDrag ||
                                   value.predictedEndTranslation.height > sheetHeight * 0.5 {
                                    dismiss()
                                } else {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isPresented)
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            dragOffset = 0
            isPresented = false
        }
    }
}

// MARK: - View Modifier

public extension View {
    func donkeySheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        detent: SheetDetent = .medium,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        ZStack {
            self
            DonkeyBottomSheet(
                isPresented: isPresented,
                detent: detent,
                content: content
            )
        }
    }
}

// MARK: - Preview

struct DonkeyBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    private struct PreviewWrapper: View {
        @State private var showMedium = true
        @State private var showLarge = false

        var body: some View {
            ZStack {
                VStack(spacing: 16) {
                    Text("Main Content")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Button("Show Medium Sheet") { showMedium = true }
                    Button("Show Large Sheet") { showLarge = true }
                }

                DonkeyBottomSheet(isPresented: $showMedium, detent: .medium) {
                    VStack(spacing: 16) {
                        Text("Medium Sheet")
                            .font(.headline)

                        Text("Drag down to dismiss or tap the background.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Spacer()
                    }
                    .padding()
                }

                DonkeyBottomSheet(isPresented: $showLarge, detent: .large) {
                    VStack(spacing: 16) {
                        Text("Large Sheet")
                            .font(.headline)

                        ForEach(0..<8, id: \.self) { i in
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.orange)
                                Text("Item \(i + 1)")
                                Spacer()
                            }
                            .padding(.horizontal)
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}
