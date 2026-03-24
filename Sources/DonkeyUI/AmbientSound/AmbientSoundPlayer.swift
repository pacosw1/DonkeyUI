//
//  AmbientSoundPlayer.swift
//  DonkeyUI
//
//  Observable audio engine for looping ambient sounds.
//  Configures AVAudioSession to mix with other audio (music, podcasts)
//  and optionally duck them. Supports bundle files and remote URLs.
//

import SwiftUI

#if canImport(AVFoundation)
import AVFoundation

// MARK: - AmbientSoundPlayer

@available(iOS 17.0, macOS 14.0, *)
@Observable
@MainActor
public final class AmbientSoundPlayer {

    // MARK: - Public State

    /// The currently selected sound.
    public var selected: AmbientSound

    /// Current volume (0...1). Changes are applied with a fade.
    public var volume: Float {
        didSet {
            let clamped = min(max(volume, 0), 1)
            if clamped != volume { volume = clamped }
            audioPlayer?.setVolume(clamped, fadeDuration: fadeDuration)
        }
    }

    /// Whether audio is currently playing.
    public private(set) var isPlaying: Bool = false

    // MARK: - Configuration

    /// Available sounds the user can pick from.
    public var sounds: [AmbientSound]

    /// Duration of volume fade transitions in seconds.
    public var fadeDuration: TimeInterval

    /// Whether to duck other audio (music) when playing.
    public var ducksOtherAudio: Bool

    // MARK: - Private

    private var audioPlayer: AVAudioPlayer?
    private var remoteDownloadTask: URLSessionDataTask?

    // MARK: - Init

    /// Creates a new ambient sound player.
    ///
    /// - Parameters:
    ///   - sounds: The list of sounds to offer. Defaults to ``AmbientSound/defaults``.
    ///   - fadeDuration: How long volume fades take (seconds). Default `1.0`.
    ///   - ducksOtherAudio: Whether to lower other audio while ambient plays. Default `true`.
    public init(
        sounds: [AmbientSound] = AmbientSound.defaults,
        fadeDuration: TimeInterval = 1.0,
        ducksOtherAudio: Bool = true
    ) {
        self.sounds = sounds
        self.fadeDuration = fadeDuration
        self.ducksOtherAudio = ducksOtherAudio
        let initial = sounds.first ?? .off
        self.selected = initial
        self.volume = initial.defaultVolume
    }

    // MARK: - Playback

    /// Select a sound and start playing it.
    public func select(_ sound: AmbientSound) {
        let wasPlaying = isPlaying
        stop()
        selected = sound
        volume = sound.defaultVolume
        if wasPlaying || sound.id != AmbientSound.off.id {
            play()
        }
    }

    /// Start playing the currently selected sound in a loop.
    public func play() {
        guard selected.id != AmbientSound.off.id else {
            stop()
            return
        }

        configureAudioSession()

        switch selected.source {
        case .bundle(let name, let ext):
            playBundleSound(name: name, ext: ext)
        case .remote(let url):
            playRemoteSound(url: url)
        }
    }

    /// Pause playback (can be resumed).
    public func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }

    /// Resume paused playback.
    public func resume() {
        guard audioPlayer != nil else {
            play()
            return
        }
        audioPlayer?.play()
        isPlaying = audioPlayer?.isPlaying ?? false
    }

    /// Stop playback and release the player.
    public func stop() {
        remoteDownloadTask?.cancel()
        remoteDownloadTask = nil

        if let player = audioPlayer {
            player.setVolume(0, fadeDuration: fadeDuration * 0.5)
            // Delay actual stop to allow fade-out
            let playerRef = player
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration * 0.5) {
                playerRef.stop()
            }
        }
        audioPlayer = nil
        isPlaying = false
    }

    /// Toggle between playing and paused.
    public func toggle() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    /// Add a new sound to the available list.
    public func addSound(_ sound: AmbientSound) {
        guard !sounds.contains(where: { $0.id == sound.id }) else { return }
        sounds.append(sound)
    }

    /// Add multiple sounds at once.
    public func addSounds(_ newSounds: [AmbientSound]) {
        for sound in newSounds {
            addSound(sound)
        }
    }

    // MARK: - Private Helpers

    private func configureAudioSession() {
        #if os(iOS) || os(watchOS) || os(tvOS)
        do {
            var options: AVAudioSession.CategoryOptions = [.mixWithOthers]
            if ducksOtherAudio {
                options.insert(.duckOthers)
            }
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: options
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Non-fatal — audio may still work
        }
        #endif
    }

    private func playBundleSound(name: String, ext: String) {
        guard !name.isEmpty else { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }
        startPlayer(with: url)
    }

    private func playRemoteSound(url: URL) {
        // If it's already cached in temp, play directly
        let cachedURL = cachedFileURL(for: url)
        if FileManager.default.fileExists(atPath: cachedURL.path) {
            startPlayer(with: cachedURL)
            return
        }

        // Download then play
        remoteDownloadTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data, error == nil else { return }
            do {
                try data.write(to: cachedURL)
                DispatchQueue.main.async {
                    self?.startPlayer(with: cachedURL)
                }
            } catch {
                // Download failed silently
            }
        }
        remoteDownloadTask?.resume()
    }

    private func startPlayer(with url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // loop forever
            player.volume = 0
            player.play()
            player.setVolume(volume, fadeDuration: fadeDuration)
            audioPlayer = player
            isPlaying = true
        } catch {
            isPlaying = false
        }
    }

    private func cachedFileURL(for remoteURL: URL) -> URL {
        let filename = remoteURL.lastPathComponent
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("donkey_ambient_\(filename)")
    }
}

#else

// MARK: - AmbientSoundPlayer (no-op for platforms without AVFoundation)

@available(iOS 17.0, macOS 14.0, *)
@Observable
@MainActor
public final class AmbientSoundPlayer {
    public var selected: AmbientSound
    public var volume: Float = 1.0
    public private(set) var isPlaying: Bool = false
    public var sounds: [AmbientSound]
    public var fadeDuration: TimeInterval = 1.0
    public var ducksOtherAudio: Bool = true

    public init(
        sounds: [AmbientSound] = AmbientSound.defaults,
        fadeDuration: TimeInterval = 1.0,
        ducksOtherAudio: Bool = true
    ) {
        self.sounds = sounds
        self.fadeDuration = fadeDuration
        self.ducksOtherAudio = ducksOtherAudio
        self.selected = sounds.first ?? .off
    }

    public func select(_ sound: AmbientSound) { selected = sound }
    public func play() {}
    public func pause() {}
    public func resume() {}
    public func stop() {}
    public func toggle() {}
    public func addSound(_ sound: AmbientSound) { sounds.append(sound) }
    public func addSounds(_ newSounds: [AmbientSound]) { sounds.append(contentsOf: newSounds) }
}

#endif
