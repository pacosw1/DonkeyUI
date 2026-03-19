import SwiftUI

// MARK: - DonkeySearchBar

public struct DonkeySearchBar: View {
    @Binding var text: String
    var placeholder: String
    var showCancel: Bool
    var onSubmit: (() -> Void)?

    @Environment(\.donkeyTheme) var theme
    @State private var debouncedText: String = ""
    @State private var isEditing: Bool = false
    @FocusState private var isFocused: Bool

    public init(
        text: Binding<String>,
        placeholder: String = "Search",
        showCancel: Bool = true,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.showCancel = showCancel
        self.onSubmit = onSubmit
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.secondary)

                TextField(placeholder, text: $text)
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.onSurface)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit { onSubmit?() }
                    .task(id: text) {
                        do {
                            try await Task.sleep(nanoseconds: 300_000_000)
                            debouncedText = text
                        } catch {}
                    }
                    #if canImport(UIKit)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    #endif

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(theme.typography.body)
                            .foregroundColor(theme.colors.secondary)
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.vertical, theme.spacing.sm + 2)
            .padding(.horizontal, theme.spacing.md)
            .bgOverlay(
                bgColor: theme.colors.surface,
                radius: theme.shape.radiusMedium,
                borderColor: isFocused ? theme.colors.primary.opacity(0.5) : .clear,
                borderWidth: 1.5
            )

            if showCancel && isEditing {
                Button("Cancel") {
                    text = ""
                    isFocused = false
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditing = false
                    }
                }
                .font(theme.typography.body)
                .foregroundColor(theme.colors.primary)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
        .animation(.easeInOut(duration: 0.2), value: isEditing)
        .onChange(of: isFocused) { _, focused in
            withAnimation(.easeInOut(duration: 0.2)) {
                isEditing = focused
            }
        }
    }

    /// The debounced text value, updated 0.3s after the user stops typing.
    public var debounced: String {
        debouncedText
    }
}

// MARK: - Preview

struct DonkeySearchBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            DonkeySearchBar(text: .constant(""), placeholder: "Search products...")
            DonkeySearchBar(text: .constant("iPhone"), placeholder: "Search...")
            DonkeySearchBar(text: .constant(""), placeholder: "No cancel", showCancel: false)
        }
        .padding()
    }
}
