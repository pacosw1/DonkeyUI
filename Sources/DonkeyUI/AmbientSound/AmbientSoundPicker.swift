//
//  AmbientSoundPicker.swift
//  DonkeyUI
//
//  SwiftUI view for selecting and controlling ambient sounds.
//  Displays a grid of sound options with volume slider and play controls.
//

import SwiftUI

// MARK: - AmbientSoundPicker

@available(iOS 17.0, macOS 14.0, *)
public struct AmbientSoundPicker: View {

    // MARK: - Properties

    @Bindable var player: AmbientSoundPlayer
    @Environment(\.donkeyTheme) private var theme

    var columns: Int

    // MARK: - Init

    /// Creates an ambient sound picker.
    ///
    /// - Parameters:
    ///   - player: The ``AmbientSoundPlayer`` instance that manages playback.
    ///   - columns: Number of columns in the sound grid. Default `3`.
    public init(
        player: AmbientSoundPlayer,
        columns: Int = 3
    ) {
        self.player = player
        self.columns = columns
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: theme.spacing.md) {
            volumeSlider
            soundGrid
        }
    }

    // MARK: - Volume Slider

    private var volumeSlider: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: volumeIcon)
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.secondary)
                .frame(width: 20)

            Slider(value: Binding(
                get: { Double(player.volume) },
                set: { player.volume = Float($0) }
            ), in: 0...1)
            .tint(theme.colors.primary.opacity(Double(max(0.3, player.volume))))
            .disabled(player.selected.id == AmbientSound.off.id)
        }
    }

    private var volumeIcon: String {
        if player.selected.id == AmbientSound.off.id || player.volume == 0 {
            return "speaker.slash.fill"
        } else if player.volume < 0.33 {
            return "speaker.fill"
        } else if player.volume < 0.66 {
            return "speaker.wave.1.fill"
        } else {
            return "speaker.wave.2.fill"
        }
    }

    // MARK: - Sound Grid

    private var soundGrid: some View {
        let gridColumns = Array(
            repeating: GridItem(.flexible(), spacing: theme.spacing.sm),
            count: columns
        )

        return LazyVGrid(columns: gridColumns, spacing: theme.spacing.sm) {
            ForEach(player.sounds) { sound in
                AmbientSoundCell(
                    sound: sound,
                    isSelected: sound.id == player.selected.id,
                    isPlaying: player.isPlaying && sound.id == player.selected.id
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        player.select(sound)
                    }
                }
            }
        }
    }
}

// MARK: - AmbientSoundCell

@available(iOS 17.0, macOS 14.0, *)
public struct AmbientSoundCell: View {

    let sound: AmbientSound
    let isSelected: Bool
    let isPlaying: Bool
    let action: () -> Void

    @Environment(\.donkeyTheme) private var theme

    public init(
        sound: AmbientSound,
        isSelected: Bool,
        isPlaying: Bool,
        action: @escaping () -> Void
    ) {
        self.sound = sound
        self.isSelected = isSelected
        self.isPlaying = isPlaying
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: theme.spacing.xs) {
                Image(systemName: sound.icon)
                    .font(.title2)
                    .symbolEffect(.pulse, isActive: isPlaying)
                    .foregroundColor(isSelected ? theme.colors.primary : theme.colors.secondary)
                    .frame(height: 28)

                Text(sound.name)
                    .font(theme.typography.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? theme.colors.onSurface : theme.colors.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacing.sm)
            .padding(.horizontal, theme.spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: theme.shape.radiusSmall, style: .continuous)
                    .fill(isSelected
                          ? theme.colors.primary.opacity(0.1)
                          : theme.colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.shape.radiusSmall, style: .continuous)
                    .strokeBorder(
                        isSelected ? theme.colors.primary.opacity(0.3) : .clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(sound.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Compact Variant

@available(iOS 17.0, macOS 14.0, *)
public struct AmbientSoundMiniControl: View {

    @Bindable var player: AmbientSoundPlayer
    @Environment(\.donkeyTheme) private var theme

    /// A compact inline control — shows current sound icon with play/pause toggle.
    public init(player: AmbientSoundPlayer) {
        self.player = player
    }

    public var body: some View {
        Button {
            player.toggle()
        } label: {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: player.selected.icon)
                    .symbolEffect(.pulse, isActive: player.isPlaying)

                if player.isPlaying {
                    Image(systemName: "pause.fill")
                        .font(.caption2)
                } else {
                    Image(systemName: "play.fill")
                        .font(.caption2)
                }
            }
            .foregroundColor(player.isPlaying ? theme.colors.primary : theme.colors.secondary)
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .background(
                Capsule()
                    .fill(theme.colors.surface)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(player.isPlaying ? "Pause ambient sound" : "Play ambient sound")
    }
}

// MARK: - View Modifier for Sheet Presentation

@available(iOS 17.0, macOS 14.0, *)
private struct AmbientSoundSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let player: AmbientSoundPlayer
    let columns: Int

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                AmbientSoundPicker(player: player, columns: columns)
                    .padding()
                    .presentationDetents([.height(280)])
            }
    }
}

@available(iOS 17.0, macOS 14.0, *)
public extension View {
    /// Presents an ambient sound picker sheet.
    ///
    /// - Parameters:
    ///   - isPresented: Binding controlling sheet visibility.
    ///   - player: The ``AmbientSoundPlayer`` to control.
    ///   - columns: Grid columns for the picker. Default `3`.
    func ambientSoundPicker(
        isPresented: Binding<Bool>,
        player: AmbientSoundPlayer,
        columns: Int = 3
    ) -> some View {
        modifier(AmbientSoundSheetModifier(
            isPresented: isPresented,
            player: player,
            columns: columns
        ))
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
#Preview("Ambient Sound Picker") {
    struct AmbientDemo: View {
        @State private var player = AmbientSoundPlayer()
        @State private var showPicker = false

        var body: some View {
            VStack(spacing: 32) {
                Text("Ambient Sound")
                    .font(.title2.bold())

                AmbientSoundPicker(player: player)

                Divider()

                HStack {
                    Text("Mini control:")
                    AmbientSoundMiniControl(player: player)
                }

                Divider()

                Button("Show as Sheet") {
                    showPicker = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .ambientSoundPicker(isPresented: $showPicker, player: player)
        }
    }
    return AmbientDemo()
}
