import Foundation

#if canImport(AVFoundation)
import AVFoundation
import AudioToolbox

// MARK: - SoundManager

public struct SoundManager {

    private static let enabledKey = "donkey_sounds_enabled"

    /// Whether sounds are enabled (reads UserDefaults "donkey_sounds_enabled", defaults true).
    public static var isEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: enabledKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: enabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: enabledKey)
        }
    }

    /// Toggle sound on/off.
    public static func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    /// Play a sound from the app bundle.
    /// - Parameters:
    ///   - sound: Filename including extension, e.g. "pop.aif" or "success.mp3".
    ///   - volume: Playback volume from 0.0 to 1.0.
    public static func play(_ sound: String, volume: Float = 1.0) {
        guard isEnabled else { return }

        let components = sound.split(separator: ".", maxSplits: 1)
        let name = String(components.first ?? "")
        let ext = components.count > 1 ? String(components.last!) : nil

        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            // Retain the player until it finishes
            _retainPlayer(player)
            player.play()
        } catch {
            // Silently fail — sound is non-critical
        }
    }

    /// Play a system sound by ID.
    /// - Parameter soundID: A `SystemSoundID`, e.g. 1057 for a short tap sound.
    public static func playSystem(_ soundID: UInt32) {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(SystemSoundID(soundID))
    }

    // MARK: - Player retention

    private static var activePlayers: [AVAudioPlayer] = []
    private static let lock = NSLock()

    private static func _retainPlayer(_ player: AVAudioPlayer) {
        lock.lock()
        activePlayers.append(player)
        lock.unlock()

        // Remove after duration + small buffer
        let duration = player.duration + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            lock.lock()
            activePlayers.removeAll { $0 === player }
            lock.unlock()
        }
    }
}

#else

// MARK: - SoundManager (no-op on platforms without AVFoundation)

public struct SoundManager {

    private static let enabledKey = "donkey_sounds_enabled"

    public static var isEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: enabledKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: enabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: enabledKey)
        }
    }

    public static func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    public static func play(_ sound: String, volume: Float = 1.0) {}
    public static func playSystem(_ soundID: UInt32) {}
}

#endif
