import SwiftUI

#if canImport(AVKit)
import AVKit
#endif

#if canImport(UIKit)
import UIKit
#endif

// MARK: - VideoSource

/// Source for a video in an onboarding block.
public enum OnboardingVideoSource: Sendable {
    case bundle(name: String, extension: String)
    case url(URL)
}

// MARK: - VideoBlock

/// An inline video player block for onboarding.
/// Automatically plays when revealed, with optional looping.
public struct VideoBlock: ContentBlock, View {
    public let id: String
    public let source: OnboardingVideoSource
    public let aspectRatio: CGFloat
    public let autoplay: Bool
    public let loops: Bool
    public let showControls: Bool
    public let cornerRadius: CGFloat?
    public let timing: RevealTiming

    @Environment(\.donkeyTheme) private var theme
    @Environment(\.immersiveRevealProgress) private var progress: Double

    public init(
        id: String = UUID().uuidString,
        source: OnboardingVideoSource,
        aspectRatio: CGFloat = 16.0 / 9.0,
        autoplay: Bool = true,
        loops: Bool = true,
        showControls: Bool = false,
        cornerRadius: CGFloat? = nil,
        timing: RevealTiming = RevealTiming(duration: .seconds(0.8), style: .scaleIn)
    ) {
        self.id = id
        self.source = source
        self.aspectRatio = aspectRatio
        self.autoplay = autoplay
        self.loops = loops
        self.showControls = showControls
        self.cornerRadius = cornerRadius
        self.timing = timing
    }

    public var body: some View {
        #if canImport(AVKit)
        OnboardingVideoPlayer(
            source: source,
            aspectRatio: aspectRatio,
            autoplay: autoplay,
            loops: loops,
            showControls: showControls,
            cornerRadius: cornerRadius ?? theme.shape.radiusMedium,
            isRevealed: progress >= 0.5
        )
        .modifier(RevealModifier(progress: progress, style: timing.style))
        #else
        Text("Video not supported on this platform")
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.secondary)
        #endif
    }
}

// MARK: - Video Player View

#if canImport(AVKit)
private struct OnboardingVideoPlayer: View {
    let source: OnboardingVideoSource
    let aspectRatio: CGFloat
    let autoplay: Bool
    let loops: Bool
    let showControls: Bool
    let cornerRadius: CGFloat
    let isRevealed: Bool

    @State private var player: AVPlayer?
    @State private var loopObserver: NSObjectProtocol?

    var body: some View {
        Group {
            if let player {
                #if canImport(UIKit)
                if showControls {
                    VideoPlayer(player: player)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                } else {
                    PlayerView(player: player)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                }
                #else
                VideoPlayer(player: player)
                    .aspectRatio(aspectRatio, contentMode: .fit)
                #endif
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onAppear { setupPlayer() }
        .onDisappear {
            player?.pause()
            if let token = loopObserver {
                NotificationCenter.default.removeObserver(token)
                loopObserver = nil
            }
        }
        .onChange(of: isRevealed) { _, revealed in
            if revealed && autoplay {
                player?.play()
            }
        }
    }

    private func setupPlayer() {
        let url: URL? = {
            switch source {
            case .bundle(let name, let ext):
                return Bundle.main.url(forResource: name, withExtension: ext)
            case .url(let url):
                return url
            }
        }()

        guard let url else { return }
        let avPlayer = AVPlayer(url: url)
        avPlayer.isMuted = true

        if loops {
            let token = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: avPlayer.currentItem,
                queue: .main
            ) { _ in
                avPlayer.seek(to: .zero)
                avPlayer.play()
            }
            self.loopObserver = token
        }

        self.player = avPlayer
    }
}

#if canImport(UIKit)
/// Simple AVPlayer rendering view without playback controls.
private struct PlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        let view = PlayerUIView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    private class PlayerUIView: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }
}
#endif // UIKit
#endif // AVKit
