//
//  CelebrationModifier.swift
//  DonkeyUI
//
//  Combined celebration effect: confetti + sparkle + glow ring + optional sound.
//  Fires when `isActive` becomes true, auto-dismisses after 3 seconds.
//

import SwiftUI
#if canImport(AVFoundation)
import AVFoundation
#endif

// MARK: - Celebration Modifier

@available(iOS 17.0, macOS 14.0, *)
private struct CelebrationModifier: ViewModifier {
    @Binding var isActive: Bool
    let confettiColors: [Color]
    let sound: String?

    @State private var confettiView = DonkeyConfettiView()
    @State private var showEffects = false
    @State private var viewCenter: CGPoint = .zero
    #if canImport(AVFoundation)
    @State private var audioPlayer: AVAudioPlayer?
    #endif

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            let frame = geo.frame(in: .global)
                            viewCenter = CGPoint(x: frame.midX, y: frame.midY)
                        }
                }
            )
            .overlay {
                ZStack {
                    // Glow ring centered on view
                    DonkeyGlowRingView(isActive: showEffects)
                        .position(viewCenter)

                    // Sparkle centered on view
                    DonkeySparkleView(
                        isActive: showEffects,
                        centerX: viewCenter.x,
                        centerY: viewCenter.y,
                        radius: 100
                    )

                    // Confetti overlay
                    DonkeyConfettiView(colors: confettiColors)
                        .onAppear {
                            confettiView = DonkeyConfettiView(colors: confettiColors)
                        }
                }
                .allowsHitTesting(false)
                .ignoresSafeArea()
            }
            .confetti(trigger: isActive, colors: confettiColors)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    showEffects = true
                    playSound()

                    // Auto-dismiss after 3 seconds
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(3))
                        showEffects = false
                        isActive = false
                    }
                }
            }
    }

    private func playSound() {
        #if canImport(AVFoundation)
        guard let soundName = sound else { return }

        // Try to find the sound file in the main bundle
        let extensions = ["aif", "aiff", "wav", "mp3", "m4a", "caf"]
        var url: URL?

        // First try the exact name (might include extension)
        if let dotIndex = soundName.lastIndex(of: ".") {
            let name = String(soundName[soundName.startIndex..<dotIndex])
            let ext = String(soundName[soundName.index(after: dotIndex)...])
            url = Bundle.main.url(forResource: name, withExtension: ext)
        }

        // Fallback: try common extensions
        if url == nil {
            for ext in extensions {
                if let found = Bundle.main.url(forResource: soundName, withExtension: ext) {
                    url = found
                    break
                }
            }
        }

        guard let soundURL = url else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            // Silent fail — sound is optional
        }
        #endif
    }
}

// MARK: - View Extension

@available(iOS 17.0, macOS 14.0, *)
public extension View {
    /// Adds a combined celebration effect (confetti + sparkle + glow ring + optional sound).
    ///
    /// When `isActive` becomes `true`, the celebration fires and auto-dismisses after 3 seconds.
    ///
    /// - Parameters:
    ///   - isActive: Binding that triggers the celebration when set to `true`. Automatically reset to `false` after 3 seconds.
    ///   - confettiColors: Colors for the confetti particles.
    ///   - sound: Optional bundle sound file name (e.g. `"pop.aif"`). Pass `nil` for no sound.
    func celebration(
        isActive: Binding<Bool>,
        confettiColors: [Color] = [.blue, .cyan, .yellow, .orange, .pink, .green, .purple, .mint],
        sound: String? = nil
    ) -> some View {
        modifier(CelebrationModifier(
            isActive: isActive,
            confettiColors: confettiColors,
            sound: sound
        ))
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
#Preview("Celebration") {
    struct CelebrationDemo: View {
        @State private var celebrate = false
        var body: some View {
            VStack(spacing: 32) {
                Image(systemName: "star.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                    .celebration(isActive: $celebrate)

                Button("Celebrate!") {
                    celebrate = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }
    return CelebrationDemo()
}
