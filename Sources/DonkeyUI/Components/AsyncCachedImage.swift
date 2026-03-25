import SwiftUI

// MARK: - Image Cache

private final class ImageCacheStore {
    static let shared = ImageCacheStore()
    let cache = NSCache<NSURL, ImageData>()

    init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
}

// MARK: - ImageData (platform-agnostic wrapper)

public final class ImageData: NSObject {
    public let data: Data

    #if canImport(UIKit)
    public let image: UIImage?
    #elseif canImport(AppKit)
    public let image: NSImage?
    #endif

    public init(data: Data) {
        self.data = data
        #if canImport(UIKit)
        self.image = UIImage(data: data)
        #elseif canImport(AppKit)
        self.image = NSImage(data: data)
        #endif
        super.init()
    }
}

// MARK: - AsyncCachedImage

public struct AsyncCachedImage: View {
    let url: URL?
    let placeholder: AnyView?
    let cornerRadius: CGFloat

    @Environment(\.donkeyTheme) var theme
    @State private var imageData: ImageData?
    @State private var isLoading = false
    @State private var hasFailed = false

    public init(
        url: URL?,
        placeholder: AnyView? = nil,
        cornerRadius: CGFloat = 8
    ) {
        self.url = url
        self.placeholder = placeholder
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        Group {
            if let imageData = imageData, let image = imageData.image {
                #if canImport(UIKit)
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                #elseif canImport(AppKit)
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                #endif
            } else if hasFailed {
                failedView
            } else if isLoading {
                loadingView
            } else {
                loadingView
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .task(id: url) {
            await loadImage()
        }
    }

    private var loadingView: some View {
        Group {
            if let placeholder = placeholder {
                placeholder
            } else {
                shimmerPlaceholder
            }
        }
    }

    private var shimmerPlaceholder: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(theme.colors.surface)
            .overlay {
                ShimmerEffect()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
    }

    private var failedView: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(theme.colors.surface)
            .overlay {
                Image(systemName: "photo")
                    .font(theme.typography.title2)
                    .foregroundStyle(theme.colors.secondary.opacity(0.5))
            }
    }

    private func loadImage() async {
        guard let url = url else {
            hasFailed = true
            return
        }

        let nsURL = url as NSURL

        // Check cache
        if let cached = ImageCacheStore.shared.cache.object(forKey: nsURL) {
            self.imageData = cached
            return
        }

        isLoading = true
        hasFailed = false

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let loaded = ImageData(data: data)

            guard loaded.image != nil else {
                hasFailed = true
                isLoading = false
                return
            }

            ImageCacheStore.shared.cache.setObject(loaded, forKey: nsURL, cost: data.count)

            withAnimation(.easeIn(duration: 0.2)) {
                self.imageData = loaded
            }
        } catch {
            hasFailed = true
        }

        isLoading = false
    }
}

// MARK: - Shimmer Effect

private struct ShimmerEffect: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                stops: [
                    .init(color: .clear, location: max(0, phase - 0.3)),
                    .init(color: Color.white.opacity(0.3), location: phase),
                    .init(color: .clear, location: min(1, phase + 0.3))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase = 2
            }
        }
    }
}

// MARK: - Preview

struct AsyncCachedImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Valid image
            AsyncCachedImage(
                url: URL(string: "https://picsum.photos/200/200"),
                cornerRadius: 16
            )
            .frame(width: 120, height: 120)

            // No URL (failed state)
            AsyncCachedImage(url: nil, cornerRadius: 12)
                .frame(width: 100, height: 100)

            // Circular avatar
            AsyncCachedImage(
                url: URL(string: "https://picsum.photos/100/100"),
                cornerRadius: 999
            )
            .frame(width: 64, height: 64)

            // With custom placeholder
            AsyncCachedImage(
                url: URL(string: "https://picsum.photos/300/200"),
                placeholder: AnyView(
                    Color.purple.opacity(0.2)
                        .overlay {
                            ProgressView()
                        }
                ),
                cornerRadius: 8
            )
            .frame(width: 200, height: 130)
        }
        .padding()
    }
}
