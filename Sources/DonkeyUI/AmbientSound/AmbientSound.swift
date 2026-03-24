//
//  AmbientSound.swift
//  DonkeyUI
//
//  Model describing an ambient sound that can be played in a loop.
//  Supports both local bundle files and remote URLs.
//

import SwiftUI

// MARK: - AmbientSoundSource

/// Where the audio file lives.
public enum AmbientSoundSource: Sendable, Equatable {
    /// A file bundled with the app. Provide the filename without extension
    /// and the extension separately (e.g. `"Fireplace"`, `"wav"`).
    case bundle(name: String, ext: String)

    /// A remote URL. The player will stream or download before playing.
    case remote(URL)
}

// MARK: - AmbientSound

/// Describes a single ambient sound option.
public struct AmbientSound: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let icon: String
    public let source: AmbientSoundSource
    public let defaultVolume: Float

    public init(
        id: String = UUID().uuidString,
        name: String,
        icon: String,
        source: AmbientSoundSource,
        defaultVolume: Float = 1.0
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.source = source
        self.defaultVolume = min(max(defaultVolume, 0), 1)
    }

    public static func == (lhs: AmbientSound, rhs: AmbientSound) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Built-in Presets

public extension AmbientSound {

    /// No sound / silence.
    static let off = AmbientSound(
        id: "off",
        name: "Off",
        icon: "speaker.slash.fill",
        source: .bundle(name: "", ext: ""),
        defaultVolume: 0
    )

    /// Crackling fireplace.
    static let fireplace = AmbientSound(
        id: "fireplace",
        name: "Fireplace",
        icon: "flame.fill",
        source: .bundle(name: "Fireplace", ext: "wav"),
        defaultVolume: 1.0
    )

    /// Relaxing ambient tones.
    static let relax = AmbientSound(
        id: "relax",
        name: "Relax",
        icon: "leaf.fill",
        source: .bundle(name: "Relax", ext: "wav"),
        defaultVolume: 1.0
    )

    /// Forest birds and nature.
    static let forest = AmbientSound(
        id: "forest",
        name: "Forest",
        icon: "tree.fill",
        source: .bundle(name: "Forest", ext: "wav"),
        defaultVolume: 1.0
    )

    /// Ocean waves.
    static let ocean = AmbientSound(
        id: "ocean",
        name: "Ocean",
        icon: "water.waves",
        source: .bundle(name: "Ocean", ext: "wav"),
        defaultVolume: 0.4
    )

    /// Rainfall.
    static let rain = AmbientSound(
        id: "rain",
        name: "Rain",
        icon: "cloud.rain.fill",
        source: .bundle(name: "Rain", ext: "wav"),
        defaultVolume: 0.2
    )

    /// Thunder storm.
    static let storm = AmbientSound(
        id: "storm",
        name: "Storm",
        icon: "cloud.bolt.rain.fill",
        source: .bundle(name: "Storm", ext: "wav"),
        defaultVolume: 0.6
    )

    /// The default preset list shipped with DonkeyUI.
    static let defaults: [AmbientSound] = [
        .off, .fireplace, .relax, .forest, .ocean, .rain, .storm
    ]
}
