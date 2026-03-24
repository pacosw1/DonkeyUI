//
//  TimeBlocksView.swift
//  DonkeyUI
//
//  Grid-based progress visualization using colored circles.
//  Displays completed vs remaining blocks in configurable color modes.
//  Ported from Sandwatch.
//

import SwiftUI

// MARK: - BlockColorMode

public enum BlockColorMode: String, CaseIterable, Sendable {
    case single = "Single"
    case duo = "Duo"
    case party = "Party"
}

// MARK: - TimeBlocksView

@available(iOS 17.0, macOS 14.0, *)
public struct TimeBlocksView: View {

    // MARK: - Properties

    public let completedBlocks: Int
    public let totalBlocks: Int
    public let blocksPerRow: Int
    public var colorMode: BlockColorMode
    public var completedColor: Color
    public var activeColor: Color
    public var blockSpacing: CGFloat

    // MARK: - Init

    public init(
        completedBlocks: Int,
        totalBlocks: Int,
        blocksPerRow: Int = 52,
        colorMode: BlockColorMode = .single,
        completedColor: Color = .gray.opacity(0.3),
        activeColor: Color = .blue,
        blockSpacing: CGFloat = 3
    ) {
        self.completedBlocks = completedBlocks
        self.totalBlocks = totalBlocks
        self.blocksPerRow = blocksPerRow
        self.colorMode = colorMode
        self.completedColor = completedColor
        self.activeColor = activeColor
        self.blockSpacing = blockSpacing
    }

    // MARK: - Color Palettes

    private var palette: [Color] {
        switch colorMode {
        case .single:
            return [activeColor]
        case .duo:
            return [.blue, .purple]
        case .party:
            return [.pink, .orange, .teal, .yellow, .mint]
        }
    }

    private func remainingColor() -> Color {
        palette.randomElement()!.opacity(0.6)
    }

    // MARK: - Body

    public var body: some View {
        let rowCount = totalBlocks / max(blocksPerRow, 1)

        VStack(alignment: .leading, spacing: blockSpacing) {
            ForEach(0..<rowCount, id: \.self) { rowIndex in
                HStack(spacing: blockSpacing) {
                    ForEach(0..<blocksPerRow, id: \.self) { colIndex in
                        let blockIndex = rowIndex * blocksPerRow + colIndex
                        Circle()
                            .fill(blockIndex < completedBlocks ? completedColor : remainingColor())
                    }
                }
            }
        }
        .accessibilityLabel("\(completedBlocks) of \(totalBlocks) blocks completed")
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
#Preview("Time Blocks") {
    ScrollView {
        VStack(spacing: 32) {
            Text("Single")
                .font(.caption.bold())
            TimeBlocksView(
                completedBlocks: 1300,
                totalBlocks: 4160,
                blocksPerRow: 52,
                colorMode: .single
            )

            Text("Duo")
                .font(.caption.bold())
            TimeBlocksView(
                completedBlocks: 1300,
                totalBlocks: 4160,
                blocksPerRow: 52,
                colorMode: .duo
            )

            Text("Party")
                .font(.caption.bold())
            TimeBlocksView(
                completedBlocks: 1300,
                totalBlocks: 4160,
                blocksPerRow: 52,
                colorMode: .party
            )
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
