#if !os(watchOS)
import SwiftUI

public struct ThemedShareButton<Data: Transferable>: View {
    @Environment(\.donkeyTheme) var theme

    let label: String
    let icon: String
    let item: Data
    let preview: SharePreview<Never, Never>

    public init(
        _ label: String = "Share",
        icon: String = "square.and.arrow.up",
        item: Data,
        preview: SharePreview<Never, Never>
    ) {
        self.label = label
        self.icon = icon
        self.item = item
        self.preview = preview
    }

    public var body: some View {
        ShareLink(item: item, preview: preview) {
            Label(label, systemImage: icon)
                .font(theme.typography.body)
                .fontWeight(theme.typography.emphasisWeight)
                .foregroundColor(theme.colors.primary)
                .padding(.horizontal, theme.spacing.lg)
                .padding(.vertical, theme.spacing.sm)
                .background(theme.colors.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: theme.shape.radiusMedium))
        }
    }
}

// Convenience init for string sharing
public extension ThemedShareButton where Data == String {
    init(_ label: String = "Share", icon: String = "square.and.arrow.up", text: String) {
        self.init(label, icon: icon, item: text, preview: SharePreview(text))
    }
}

// Convenience init for URL sharing
public extension ThemedShareButton where Data == URL {
    init(_ label: String = "Share", icon: String = "square.and.arrow.up", url: URL, title: String? = nil) {
        self.init(label, icon: icon, item: url, preview: SharePreview(title ?? url.absoluteString))
    }
}

// MARK: - Preview
struct ThemedShareButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ThemedShareButton(text: "Hello, world!")
            ThemedShareButton(url: URL(string: "https://example.com")!, title: "Example")
        }
        .padding()
    }
}
#endif
