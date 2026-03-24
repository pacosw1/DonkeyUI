//
//  AmbientSoundTests.swift
//  DonkeyUITests
//
//  Comprehensive tests for the AmbientSound model, AmbientSoundPlayer,
//  and AmbientSoundPicker. Audio playback is not tested because
//  AVAudioPlayer requires real audio files that aren't present in
//  the test bundle. We focus on state management and logic.
//

import XCTest
import SwiftUI
@testable import DonkeyUI

// MARK: - AmbientSound Model Tests

final class AmbientSoundModelTests: XCTestCase {

    // MARK: Presets Exist

    func testOffPresetProperties() {
        let off = AmbientSound.off
        XCTAssertEqual(off.id, "off")
        XCTAssertEqual(off.name, "Off")
        XCTAssertEqual(off.icon, "speaker.slash.fill")
        XCTAssertEqual(off.defaultVolume, 0)
        XCTAssertEqual(off.source, .bundle(name: "", ext: ""))
    }

    func testFireplacePresetProperties() {
        let fp = AmbientSound.fireplace
        XCTAssertEqual(fp.id, "fireplace")
        XCTAssertEqual(fp.name, "Fireplace")
        XCTAssertEqual(fp.icon, "flame.fill")
        XCTAssertEqual(fp.defaultVolume, 1.0)
        XCTAssertEqual(fp.source, .bundle(name: "Fireplace", ext: "wav"))
    }

    func testRelaxPresetProperties() {
        let s = AmbientSound.relax
        XCTAssertEqual(s.id, "relax")
        XCTAssertEqual(s.name, "Relax")
        XCTAssertEqual(s.icon, "leaf.fill")
        XCTAssertEqual(s.defaultVolume, 1.0)
    }

    func testForestPresetProperties() {
        let s = AmbientSound.forest
        XCTAssertEqual(s.id, "forest")
        XCTAssertEqual(s.name, "Forest")
        XCTAssertEqual(s.icon, "tree.fill")
        XCTAssertEqual(s.defaultVolume, 1.0)
    }

    func testOceanPresetProperties() {
        let s = AmbientSound.ocean
        XCTAssertEqual(s.id, "ocean")
        XCTAssertEqual(s.name, "Ocean")
        XCTAssertEqual(s.icon, "water.waves")
        XCTAssertEqual(s.defaultVolume, 0.4, accuracy: 0.001)
    }

    func testRainPresetProperties() {
        let s = AmbientSound.rain
        XCTAssertEqual(s.id, "rain")
        XCTAssertEqual(s.name, "Rain")
        XCTAssertEqual(s.icon, "cloud.rain.fill")
        XCTAssertEqual(s.defaultVolume, 0.2, accuracy: 0.001)
    }

    func testStormPresetProperties() {
        let s = AmbientSound.storm
        XCTAssertEqual(s.id, "storm")
        XCTAssertEqual(s.name, "Storm")
        XCTAssertEqual(s.icon, "cloud.bolt.rain.fill")
        XCTAssertEqual(s.defaultVolume, 0.6, accuracy: 0.001)
    }

    // MARK: Defaults Array

    func testDefaultsArrayCount() {
        XCTAssertEqual(AmbientSound.defaults.count, 7)
    }

    func testDefaultsArrayFirstIsOff() {
        XCTAssertEqual(AmbientSound.defaults.first, .off)
    }

    func testDefaultsArrayContainsAllPresets() {
        let ids = AmbientSound.defaults.map(\.id)
        XCTAssertTrue(ids.contains("off"))
        XCTAssertTrue(ids.contains("fireplace"))
        XCTAssertTrue(ids.contains("relax"))
        XCTAssertTrue(ids.contains("forest"))
        XCTAssertTrue(ids.contains("ocean"))
        XCTAssertTrue(ids.contains("rain"))
        XCTAssertTrue(ids.contains("storm"))
    }

    func testDefaultsArrayHasUniqueIds() {
        let ids = AmbientSound.defaults.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "Default sounds should have unique IDs")
    }

    // MARK: Equatable

    func testEquatableSameId() {
        let a = AmbientSound(id: "test", name: "A", icon: "a", source: .bundle(name: "A", ext: "wav"))
        let b = AmbientSound(id: "test", name: "B", icon: "b", source: .bundle(name: "B", ext: "mp3"))
        XCTAssertEqual(a, b, "Sounds with the same id should be equal regardless of other properties")
    }

    func testEquatableDifferentId() {
        let a = AmbientSound(id: "one", name: "Same", icon: "same", source: .bundle(name: "Same", ext: "wav"))
        let b = AmbientSound(id: "two", name: "Same", icon: "same", source: .bundle(name: "Same", ext: "wav"))
        XCTAssertNotEqual(a, b, "Sounds with different ids should not be equal even with identical other properties")
    }

    func testEquatablePresets() {
        XCTAssertEqual(AmbientSound.off, AmbientSound.off)
        XCTAssertNotEqual(AmbientSound.off, AmbientSound.fireplace)
    }

    // MARK: Custom Sound Creation

    func testCustomBundleSound() {
        let sound = AmbientSound(
            id: "custom-1",
            name: "My Sound",
            icon: "star.fill",
            source: .bundle(name: "CustomFile", ext: "mp3"),
            defaultVolume: 0.5
        )
        XCTAssertEqual(sound.id, "custom-1")
        XCTAssertEqual(sound.name, "My Sound")
        XCTAssertEqual(sound.icon, "star.fill")
        XCTAssertEqual(sound.source, .bundle(name: "CustomFile", ext: "mp3"))
        XCTAssertEqual(sound.defaultVolume, 0.5, accuracy: 0.001)
    }

    func testCustomRemoteSound() {
        let url = URL(string: "https://example.com/rain.wav")!
        let sound = AmbientSound(
            id: "remote-1",
            name: "Remote Rain",
            icon: "cloud.fill",
            source: .remote(url),
            defaultVolume: 0.7
        )
        XCTAssertEqual(sound.source, .remote(url))
        XCTAssertEqual(sound.defaultVolume, 0.7, accuracy: 0.001)
    }

    func testAutoGeneratedId() {
        let a = AmbientSound(name: "A", icon: "a", source: .bundle(name: "A", ext: "wav"))
        let b = AmbientSound(name: "B", icon: "b", source: .bundle(name: "B", ext: "wav"))
        XCTAssertFalse(a.id.isEmpty, "Auto-generated id should not be empty")
        XCTAssertNotEqual(a.id, b.id, "Auto-generated ids should be unique")
    }

    // MARK: Volume Clamping

    func testVolumeClampedToZeroWhenNegative() {
        let sound = AmbientSound(
            name: "Test",
            icon: "x",
            source: .bundle(name: "T", ext: "wav"),
            defaultVolume: -0.5
        )
        XCTAssertEqual(sound.defaultVolume, 0, accuracy: 0.001,
                       "Negative volume should be clamped to 0")
    }

    func testVolumeClampedToOneWhenAboveOne() {
        let sound = AmbientSound(
            name: "Test",
            icon: "x",
            source: .bundle(name: "T", ext: "wav"),
            defaultVolume: 2.5
        )
        XCTAssertEqual(sound.defaultVolume, 1.0, accuracy: 0.001,
                       "Volume above 1 should be clamped to 1")
    }

    func testVolumeBoundaryZero() {
        let sound = AmbientSound(
            name: "Test", icon: "x",
            source: .bundle(name: "T", ext: "wav"),
            defaultVolume: 0.0
        )
        XCTAssertEqual(sound.defaultVolume, 0.0, accuracy: 0.001)
    }

    func testVolumeBoundaryOne() {
        let sound = AmbientSound(
            name: "Test", icon: "x",
            source: .bundle(name: "T", ext: "wav"),
            defaultVolume: 1.0
        )
        XCTAssertEqual(sound.defaultVolume, 1.0, accuracy: 0.001)
    }

    func testVolumeClampedWithLargeNegative() {
        let sound = AmbientSound(
            name: "Test", icon: "x",
            source: .bundle(name: "T", ext: "wav"),
            defaultVolume: -100
        )
        XCTAssertEqual(sound.defaultVolume, 0, accuracy: 0.001)
    }

    func testVolumeClampedWithLargePositive() {
        let sound = AmbientSound(
            name: "Test", icon: "x",
            source: .bundle(name: "T", ext: "wav"),
            defaultVolume: 999
        )
        XCTAssertEqual(sound.defaultVolume, 1.0, accuracy: 0.001)
    }

    // MARK: Identifiable

    func testIdentifiable() {
        let sound = AmbientSound(id: "my-id", name: "X", icon: "x", source: .bundle(name: "X", ext: "wav"))
        // Identifiable requires an `id` property -- just verify it works as expected.
        let id: String = sound.id
        XCTAssertEqual(id, "my-id")
    }

    // MARK: Sendable

    func testSendableConformance() {
        // AmbientSound is Sendable. Verify we can pass it across isolation boundaries.
        let sound: any Sendable = AmbientSound.fireplace
        XCTAssertNotNil(sound)
    }

    // MARK: AmbientSoundSource Equatable

    func testSourceBundleEquality() {
        XCTAssertEqual(
            AmbientSoundSource.bundle(name: "A", ext: "wav"),
            AmbientSoundSource.bundle(name: "A", ext: "wav")
        )
        XCTAssertNotEqual(
            AmbientSoundSource.bundle(name: "A", ext: "wav"),
            AmbientSoundSource.bundle(name: "B", ext: "wav")
        )
        XCTAssertNotEqual(
            AmbientSoundSource.bundle(name: "A", ext: "wav"),
            AmbientSoundSource.bundle(name: "A", ext: "mp3")
        )
    }

    func testSourceRemoteEquality() {
        let url1 = URL(string: "https://example.com/a.wav")!
        let url2 = URL(string: "https://example.com/b.wav")!
        XCTAssertEqual(AmbientSoundSource.remote(url1), AmbientSoundSource.remote(url1))
        XCTAssertNotEqual(AmbientSoundSource.remote(url1), AmbientSoundSource.remote(url2))
    }

    func testSourceBundleNotEqualToRemote() {
        let url = URL(string: "https://example.com/a.wav")!
        XCTAssertNotEqual(
            AmbientSoundSource.bundle(name: "a", ext: "wav"),
            AmbientSoundSource.remote(url)
        )
    }
}

// MARK: - AmbientSoundPlayer Tests

@available(iOS 17.0, macOS 14.0, *)
@MainActor
final class AmbientSoundPlayerTests: XCTestCase {

    // MARK: Init

    func testInitWithDefaults() {
        let player = AmbientSoundPlayer()
        XCTAssertEqual(player.sounds.count, AmbientSound.defaults.count)
        // First default is .off, so selected should be .off
        XCTAssertEqual(player.selected, .off)
        XCTAssertEqual(player.volume, AmbientSound.off.defaultVolume)
        XCTAssertFalse(player.isPlaying)
        XCTAssertEqual(player.fadeDuration, 1.0, accuracy: 0.001)
        XCTAssertTrue(player.ducksOtherAudio)
    }

    func testInitWithCustomSounds() {
        let customSounds = [AmbientSound.fireplace, AmbientSound.rain]
        let player = AmbientSoundPlayer(sounds: customSounds)
        XCTAssertEqual(player.sounds.count, 2)
        // Should select the first sound in the list
        XCTAssertEqual(player.selected, .fireplace)
        XCTAssertEqual(player.volume, AmbientSound.fireplace.defaultVolume)
    }

    func testInitWithEmptySoundsSelectsOff() {
        let player = AmbientSoundPlayer(sounds: [])
        XCTAssertEqual(player.selected, .off)
        XCTAssertTrue(player.sounds.isEmpty)
    }

    func testInitCustomFadeDuration() {
        let player = AmbientSoundPlayer(fadeDuration: 2.5)
        XCTAssertEqual(player.fadeDuration, 2.5, accuracy: 0.001)
    }

    func testInitDucksOtherAudioFalse() {
        let player = AmbientSoundPlayer(ducksOtherAudio: false)
        XCTAssertFalse(player.ducksOtherAudio)
    }

    // MARK: Select

    func testSelectUpdatesSelectedAndVolume() {
        let player = AmbientSoundPlayer()
        player.select(.rain)
        XCTAssertEqual(player.selected, .rain)
        XCTAssertEqual(player.volume, AmbientSound.rain.defaultVolume, accuracy: 0.001,
                       "Volume should update to the selected sound's default volume")
    }

    func testSelectDifferentSoundsInSequence() {
        let player = AmbientSoundPlayer()

        player.select(.ocean)
        XCTAssertEqual(player.selected, .ocean)
        XCTAssertEqual(player.volume, 0.4, accuracy: 0.001)

        player.select(.storm)
        XCTAssertEqual(player.selected, .storm)
        XCTAssertEqual(player.volume, 0.6, accuracy: 0.001)

        player.select(.fireplace)
        XCTAssertEqual(player.selected, .fireplace)
        XCTAssertEqual(player.volume, 1.0, accuracy: 0.001)
    }

    func testSelectOffSound() {
        let player = AmbientSoundPlayer(sounds: [.fireplace, .off])
        player.select(.fireplace)
        player.select(.off)
        XCTAssertEqual(player.selected, .off)
        XCTAssertEqual(player.volume, 0, accuracy: 0.001)
        // Selecting .off should stop playback
        XCTAssertFalse(player.isPlaying)
    }

    // MARK: Toggle

    func testToggleFromNotPlayingCallsResume() {
        let player = AmbientSoundPlayer()
        XCTAssertFalse(player.isPlaying)
        // toggle() when not playing calls resume(), which tries play().
        // Without real audio files, isPlaying stays false (play returns early).
        player.toggle()
        // We just verify it doesn't crash and state stays consistent.
        // isPlaying depends on AVAudioPlayer which won't work in tests.
    }

    func testToggleDoesNotCrashWhenOff() {
        let player = AmbientSoundPlayer()
        player.select(.off)
        player.toggle()
        XCTAssertFalse(player.isPlaying)
    }

    // MARK: Add Sound

    func testAddSoundAppendsNewSound() {
        let player = AmbientSoundPlayer(sounds: [.off])
        XCTAssertEqual(player.sounds.count, 1)

        let custom = AmbientSound(
            id: "custom",
            name: "Custom",
            icon: "star",
            source: .bundle(name: "Custom", ext: "wav")
        )
        player.addSound(custom)
        XCTAssertEqual(player.sounds.count, 2)
        XCTAssertEqual(player.sounds.last, custom)
    }

    func testAddSoundDoesNotDuplicate() {
        let player = AmbientSoundPlayer(sounds: [.off, .fireplace])
        XCTAssertEqual(player.sounds.count, 2)

        // Try to add fireplace again (same id)
        player.addSound(.fireplace)
        XCTAssertEqual(player.sounds.count, 2,
                       "Should not add a sound with a duplicate id")
    }

    func testAddSoundDoesNotDuplicateCustomId() {
        let player = AmbientSoundPlayer(sounds: [.off])
        let sound = AmbientSound(id: "x", name: "X", icon: "x", source: .bundle(name: "X", ext: "wav"))
        player.addSound(sound)
        player.addSound(sound)
        XCTAssertEqual(player.sounds.count, 2,
                       "Adding the same custom sound twice should only add it once")
    }

    // MARK: Add Sounds (Batch)

    func testAddSoundsBatchAddsMultiple() {
        let player = AmbientSoundPlayer(sounds: [.off])
        let newSounds = [
            AmbientSound(id: "a", name: "A", icon: "a", source: .bundle(name: "A", ext: "wav")),
            AmbientSound(id: "b", name: "B", icon: "b", source: .bundle(name: "B", ext: "wav")),
        ]
        player.addSounds(newSounds)
        XCTAssertEqual(player.sounds.count, 3)
    }

    func testAddSoundsBatchSkipsDuplicates() {
        let player = AmbientSoundPlayer(sounds: [.off, .fireplace])
        let newSounds: [AmbientSound] = [.fireplace, .rain, .ocean]
        player.addSounds(newSounds)
        // fireplace already exists, so only rain and ocean are added
        XCTAssertEqual(player.sounds.count, 4)
        let ids = player.sounds.map(\.id)
        XCTAssertTrue(ids.contains("rain"))
        XCTAssertTrue(ids.contains("ocean"))
    }

    func testAddSoundsBatchWithInternalDuplicates() {
        let player = AmbientSoundPlayer(sounds: [.off])
        let dup = AmbientSound(id: "dup", name: "Dup", icon: "d", source: .bundle(name: "D", ext: "wav"))
        // Pass the same sound twice in one batch
        player.addSounds([dup, dup])
        // addSounds iterates calling addSound, so the second one should be skipped
        XCTAssertEqual(player.sounds.count, 2)
    }

    func testAddSoundsEmptyArray() {
        let player = AmbientSoundPlayer(sounds: [.off])
        player.addSounds([])
        XCTAssertEqual(player.sounds.count, 1)
    }

    // MARK: Volume Clamping on Player

    func testPlayerVolumeClampAboveOne() {
        let player = AmbientSoundPlayer()
        player.volume = 5.0
        XCTAssertEqual(player.volume, 1.0, accuracy: 0.001,
                       "Player volume should be clamped to max 1.0")
    }

    func testPlayerVolumeClampBelowZero() {
        let player = AmbientSoundPlayer()
        player.volume = -3.0
        XCTAssertEqual(player.volume, 0, accuracy: 0.001,
                       "Player volume should be clamped to min 0")
    }

    func testPlayerVolumeAcceptsValidValues() {
        let player = AmbientSoundPlayer()
        player.volume = 0.42
        XCTAssertEqual(player.volume, 0.42, accuracy: 0.001)

        player.volume = 0
        XCTAssertEqual(player.volume, 0, accuracy: 0.001)

        player.volume = 1
        XCTAssertEqual(player.volume, 1.0, accuracy: 0.001)
    }

    // MARK: Stop

    func testStopSetsIsPlayingFalse() {
        let player = AmbientSoundPlayer()
        player.stop()
        XCTAssertFalse(player.isPlaying)
    }

    // MARK: Pause

    func testPauseSetsIsPlayingFalse() {
        let player = AmbientSoundPlayer()
        player.pause()
        XCTAssertFalse(player.isPlaying)
    }

    // MARK: Play with Off Sound

    func testPlayWithOffSoundDoesNotPlay() {
        let player = AmbientSoundPlayer()
        player.select(.off)
        player.play()
        XCTAssertFalse(player.isPlaying,
                       "Playing the 'off' sound should not set isPlaying to true")
    }

    // MARK: State Consistency

    func testSelectingOffAfterAnotherSoundResetsState() {
        let player = AmbientSoundPlayer()
        player.select(.rain)
        XCTAssertEqual(player.selected, .rain)

        player.select(.off)
        XCTAssertEqual(player.selected, .off)
        XCTAssertEqual(player.volume, 0, accuracy: 0.001)
        XCTAssertFalse(player.isPlaying)
    }

    func testSoundsPropertyIsModifiable() {
        let player = AmbientSoundPlayer(sounds: [.off])
        player.sounds = [.off, .fireplace, .rain]
        XCTAssertEqual(player.sounds.count, 3)
    }

    func testFadeDurationIsModifiable() {
        let player = AmbientSoundPlayer()
        player.fadeDuration = 3.0
        XCTAssertEqual(player.fadeDuration, 3.0, accuracy: 0.001)
    }

    func testDucksOtherAudioIsModifiable() {
        let player = AmbientSoundPlayer()
        player.ducksOtherAudio = false
        XCTAssertFalse(player.ducksOtherAudio)
        player.ducksOtherAudio = true
        XCTAssertTrue(player.ducksOtherAudio)
    }

    // MARK: Init Selects First Sound's Volume

    func testInitSetsVolumeFromFirstSound() {
        // Ocean has defaultVolume 0.4
        let player = AmbientSoundPlayer(sounds: [.ocean, .rain])
        XCTAssertEqual(player.volume, 0.4, accuracy: 0.001)
    }

    func testInitWithSingleSoundSelectsIt() {
        let player = AmbientSoundPlayer(sounds: [.storm])
        XCTAssertEqual(player.selected, .storm)
        XCTAssertEqual(player.volume, 0.6, accuracy: 0.001)
    }
}

// MARK: - AmbientSoundPicker View Tests

@available(iOS 17.0, macOS 14.0, *)
@MainActor
final class AmbientSoundPickerTests: XCTestCase {

    func testPickerInitializesWithoutCrashing() {
        let player = AmbientSoundPlayer()
        let picker = AmbientSoundPicker(player: player)
        // Verify the view can be created and its body accessed without crashing.
        _ = picker.body
    }

    func testPickerCustomColumns() {
        let player = AmbientSoundPlayer()
        let picker = AmbientSoundPicker(player: player, columns: 4)
        XCTAssertEqual(picker.columns, 4)
    }

    func testPickerDefaultColumns() {
        let player = AmbientSoundPlayer()
        let picker = AmbientSoundPicker(player: player)
        XCTAssertEqual(picker.columns, 3)
    }

    func testPickerPlayerHasCorrectSoundCount() {
        let player = AmbientSoundPlayer()
        let picker = AmbientSoundPicker(player: player)
        XCTAssertEqual(picker.player.sounds.count, 7,
                       "Picker should display all default sounds")
    }

    func testPickerWithCustomSounds() {
        let player = AmbientSoundPlayer(sounds: [.off, .rain])
        let picker = AmbientSoundPicker(player: player)
        XCTAssertEqual(picker.player.sounds.count, 2)
    }

    // MARK: AmbientSoundCell

    func testCellInitializesWithoutCrashing() {
        var actionCalled = false
        let cell = AmbientSoundCell(
            sound: .fireplace,
            isSelected: true,
            isPlaying: false
        ) {
            actionCalled = true
        }
        _ = cell.body
        XCTAssertFalse(actionCalled, "Action should not be called during init")
    }

    func testCellPropertiesStored() {
        let cell = AmbientSoundCell(
            sound: .ocean,
            isSelected: false,
            isPlaying: true
        ) {}
        XCTAssertEqual(cell.sound, .ocean)
        XCTAssertFalse(cell.isSelected)
        XCTAssertTrue(cell.isPlaying)
    }

    // MARK: AmbientSoundMiniControl

    func testMiniControlInitializesWithoutCrashing() {
        let player = AmbientSoundPlayer()
        let mini = AmbientSoundMiniControl(player: player)
        _ = mini.body
    }
}
