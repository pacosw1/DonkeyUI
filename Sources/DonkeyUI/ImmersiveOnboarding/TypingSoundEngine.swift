import Foundation

#if canImport(AVFoundation)
import AVFoundation
import AudioToolbox
#endif

#if canImport(UIKit)
import UIKit
import CoreHaptics
#endif

// MARK: - TypingSoundStyle

/// Controls haptics and sound during typewriter text reveal.
public enum TypingSoundStyle: Sendable {
    /// No haptics or sound during typing.
    case none
    /// Haptic rhythm only, no audio.
    case hapticOnly
    /// Haptic rhythm + system keyboard tick sound.
    case hapticWithSound
    /// Haptic rhythm + custom looping audio from bundle.
    case custom(sound: String, volume: Float = 0.3)
}

// MARK: - TypingSoundEngine

/// Combines:
/// - Core Haptics looping pattern (start/stop with typing)
/// - Per-character system sound ticks (fired from the typewriter loop)
@MainActor
final class TypingSoundEngine {
    private let style: TypingSoundStyle
    private var charsSinceLastTick: Int = 0

    #if canImport(UIKit)
    private var hapticEngine: CHHapticEngine?
    private var hapticPlayer: CHHapticAdvancedPatternPlayer?
    private var supportsHaptics: Bool = false
    #endif

    init(style: TypingSoundStyle) {
        self.style = style
        if case .none = style { return }
        setupHapticEngine()
    }

    // MARK: - Haptic Pattern (start/stop with typing)

    func start() {
        #if canImport(UIKit)
        guard supportsHaptics else { return }
        do {
            try hapticEngine?.start()
            try hapticPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {}
        #endif
        charsSinceLastTick = 0
    }

    func stop() {
        #if canImport(UIKit)
        do {
            try hapticPlayer?.stop(atTime: CHHapticTimeImmediate)
        } catch {}
        #endif
    }

    // MARK: - Per-Character Sound (called from typewriter loop)

    /// Call for each non-whitespace character revealed. Plays a system sound tick.
    func onCharacterRevealed() {
        guard SoundManager.isEnabled else { return }
        switch style {
        case .hapticWithSound:
            charsSinceLastTick += 1
            if charsSinceLastTick >= 4 {
                charsSinceLastTick = 0
                #if canImport(AVFoundation)
                AudioServicesPlaySystemSound(1306)
                #endif
            }
        default:
            break
        }
    }

    func shutdown() {
        stop()
        #if canImport(UIKit)
        hapticEngine?.stop()
        #endif
    }

    // MARK: - Core Haptics Setup

    private func setupHapticEngine() {
        #if canImport(UIKit)
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        guard supportsHaptics else { return }

        do {
            let engine = try CHHapticEngine()
            engine.isAutoShutdownEnabled = false
            engine.resetHandler = { [weak self] in
                try? self?.hapticEngine?.start()
            }
            try engine.start()
            self.hapticEngine = engine

            let tickInterval: TimeInterval = 0.06
            let tickCount = 50
            var events: [CHHapticEvent] = []

            for i in 0..<tickCount {
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25)
                    ],
                    relativeTime: TimeInterval(i) * tickInterval
                ))
            }

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let p = try engine.makeAdvancedPlayer(with: pattern)
            p.loopEnabled = true
            p.loopEnd = TimeInterval(tickCount) * tickInterval
            self.hapticPlayer = p
        } catch {}
        #endif
    }
}
