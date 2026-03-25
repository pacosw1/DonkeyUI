#if !os(watchOS)
import SwiftUI

/// A themed text editor with Apple Intelligence Writing Tools support (iOS 18.1+).
public struct DonkeyWritingEditor: View {
    @Environment(\.donkeyTheme) var theme
    @Binding var text: String
    let placeholder: String
    let minHeight: CGFloat

    public init(
        text: Binding<String>,
        placeholder: String = "Start writing...",
        minHeight: CGFloat = 120
    ) {
        self._text = text
        self.placeholder = placeholder
        self.minHeight = minHeight
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.onSurface)
                .scrollContentBackground(.hidden)
                .padding(theme.spacing.sm)
                .frame(minHeight: minHeight)
                .applyWritingTools()

            if text.isEmpty {
                Text(placeholder)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.secondary.opacity(0.6))
                    .padding(theme.spacing.sm)
                    .padding(.top, 8)
                    .padding(.leading, 4)
                    .allowsHitTesting(false)
            }
        }
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.shape.radiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: theme.shape.radiusMedium)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }
}

// MARK: - Writing Tools Helper

private extension View {
    @ViewBuilder
    func applyWritingTools() -> some View {
        if #available(iOS 18.1, macOS 15.1, *) {
            self.writingToolsBehavior(.complete)
        } else {
            self
        }
    }
}

// MARK: - Preview

struct DonkeyWritingEditor_Previews: PreviewProvider {
    static var previews: some View {
        DonkeyWritingEditor(text: .constant(""), placeholder: "Write something...")
            .padding()
    }
}
#endif
