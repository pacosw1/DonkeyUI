import SwiftUI

#if !os(watchOS)

// MARK: - AdaptiveColumns

/// A grid that automatically adjusts column count based on available width.
/// Uses `LazyVGrid` with adaptive grid items.
public struct AdaptiveColumns<Content: View>: View {
    @Environment(\.donkeyTheme) var theme

    let minWidth: CGFloat
    let spacing: CGFloat?
    let content: () -> Content

    public init(
        minWidth: CGFloat = 300,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.minWidth = minWidth
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: minWidth))],
            spacing: spacing ?? theme.spacing.md
        ) {
            content()
        }
    }
}

// MARK: - Preview

struct AdaptiveColumns_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            AdaptiveColumns(minWidth: 150) {
                ForEach(0..<8) { i in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.3))
                        .frame(height: 100)
                        .overlay(Text("Item \(i)"))
                }
            }
            .padding()
        }
    }
}

#endif
