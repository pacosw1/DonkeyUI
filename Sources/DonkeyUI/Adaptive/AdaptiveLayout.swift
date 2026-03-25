import SwiftUI

// MARK: - AdaptiveLayout

/// Renders compact or regular content based on horizontal size class.
/// On watchOS, always renders the compact layout.
public struct AdaptiveLayout<Compact: View, Regular: View>: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    let compact: () -> Compact
    let regular: () -> Regular

    public init(
        @ViewBuilder compact: @escaping () -> Compact,
        @ViewBuilder regular: @escaping () -> Regular
    ) {
        self.compact = compact
        self.regular = regular
    }

    public var body: some View {
        #if os(watchOS)
        compact()
        #else
        if sizeClass == .compact {
            compact()
        } else {
            regular()
        }
        #endif
    }
}

// MARK: - Preview

struct AdaptiveLayout_Previews: PreviewProvider {
    static var previews: some View {
        AdaptiveLayout {
            Text("Compact")
        } regular: {
            Text("Regular")
        }
    }
}
