#if canImport(WidgetKit)
import SwiftUI
import WidgetKit

/// Preview container that renders widget content at the approximate size for a given family.
public struct DonkeyWidgetPreviewContainer<Content: View>: View {
    private let family: WidgetFamily
    private let content: () -> Content

    public init(
        family: WidgetFamily,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.family = family
        self.content = content
    }

    public var body: some View {
        content()
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(radius: 4)
    }

    private var size: CGSize {
        switch family {
        case .systemSmall:
            return CGSize(width: 169, height: 169)
        case .systemMedium:
            return CGSize(width: 360, height: 169)
        case .systemLarge:
            return CGSize(width: 360, height: 379)
        case .systemExtraLarge:
            return CGSize(width: 715, height: 379)
        case .accessoryCircular:
            return CGSize(width: 76, height: 76)
        case .accessoryRectangular:
            return CGSize(width: 172, height: 76)
        case .accessoryInline:
            return CGSize(width: 234, height: 26)
        @unknown default:
            return CGSize(width: 169, height: 169)
        }
    }

    private var cornerRadius: CGFloat {
        switch family {
        case .accessoryCircular:
            return 38
        case .accessoryRectangular, .accessoryInline:
            return 12
        default:
            return 22
        }
    }
}

// MARK: - Preview

#Preview("Small Widget") {
    DonkeyWidgetPreviewContainer(family: .systemSmall) {
        DonkeySmallWidget {
            Image(systemName: "star.fill")
                .font(.title2)
            Text("Title")
                .font(.headline)
            Text("42")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
    .padding()
}

#Preview("Medium Widget") {
    DonkeyWidgetPreviewContainer(family: .systemMedium) {
        DonkeyMediumWidget {
            VStack(alignment: .leading) {
                Text("Left Column")
                    .font(.headline)
                Text("Details here")
                    .font(.caption)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("Right Column")
                    .font(.headline)
                Text("More info")
                    .font(.caption)
            }
        }
    }
    .padding()
}
#endif
