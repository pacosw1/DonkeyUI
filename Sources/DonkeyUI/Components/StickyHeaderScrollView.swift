import SwiftUI

// MARK: - ScrollOffsetPreferenceKey

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - StickyHeaderScrollView

public struct StickyHeaderScrollView<Header: View, Content: View>: View {
    var minHeight: CGFloat
    var maxHeight: CGFloat
    @ViewBuilder var header: () -> Header
    @ViewBuilder var content: () -> Content

    @Environment(\.donkeyTheme) var theme
    @State private var scrollOffset: CGFloat = 0

    public init(
        minHeight: CGFloat = 60,
        maxHeight: CGFloat = 260,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.header = header
        self.content = content
    }

    private var headerHeight: CGFloat {
        let range = maxHeight - minHeight
        let offset = max(0, min(-scrollOffset, range))
        return maxHeight - offset
    }

    private var headerProgress: CGFloat {
        let range = maxHeight - minHeight
        guard range > 0 else { return 0 }
        let offset = max(0, min(-scrollOffset, range))
        return offset / range
    }

    public var body: some View {
        ZStack(alignment: .top) {
            // Header
            header()
                .frame(height: headerHeight)
                .frame(maxWidth: .infinity)
                .clipped()
                .opacity(1.0 - headerProgress * 0.3)
                .zIndex(1)

            // Scrollable content
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    // Invisible spacer to track scroll offset
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geo.frame(in: .named("stickyScroll")).minY
                        )
                    }
                    .frame(height: 0)

                    // Spacer for header
                    Color.clear
                        .frame(height: maxHeight)

                    // Actual content
                    content()
                }
            }
            .coordinateSpace(name: "stickyScroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            .zIndex(0)
        }
    }
}

// MARK: - Preview

struct StickyHeaderScrollView_Previews: PreviewProvider {
    static var previews: some View {
        StickyHeaderScrollView(
            minHeight: 80,
            maxHeight: 280
        ) {
            ZStack {
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)

                    Text("Sticky Header")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        } content: {
            LazyVStack(spacing: 0) {
                ForEach(0..<30, id: \.self) { index in
                    HStack {
                        Text("Row \(index)")
                            .font(.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Divider()
                }
            }
            .background(DonkeyUIDefaults.systemBackground)
        }
        .ignoresSafeArea(edges: .top)
    }
}
