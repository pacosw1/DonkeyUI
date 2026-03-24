//
//  ProgressOutlineModifier.swift
//  DonkeyUI
//
//  Adds a trim-based progress stroke around any view.
//  Ported from WaterProgress.
//

import SwiftUI

// MARK: - ProgressOutlineModifier

@available(iOS 17.0, macOS 14.0, *)
public struct ProgressOutlineModifier: ViewModifier {

    // MARK: - Properties

    public let progress: CGFloat
    public let radius: CGFloat
    public let lineWidth: CGFloat
    public let color: Color
    public let trackColor: Color
    public let visible: Bool

    // MARK: - Init

    public init(
        progress: CGFloat,
        radius: CGFloat = 12,
        lineWidth: CGFloat = 3,
        color: Color = .accentColor,
        trackColor: Color = .gray.opacity(0.2),
        visible: Bool = true
    ) {
        self.progress = progress
        self.radius = radius
        self.lineWidth = lineWidth
        self.color = color
        self.trackColor = trackColor
        self.visible = visible
    }

    // MARK: - Body

    public func body(content: Content) -> some View {
        content
            .overlay {
                if visible {
                    ZStack {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(trackColor, lineWidth: lineWidth)

                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(), value: progress)
                    }
                }
            }
            .sensoryFeedback(.levelChange, trigger: progress)
    }
}

// MARK: - View Extension

@available(iOS 17.0, macOS 14.0, *)
public extension View {
    /// Adds a progress outline stroke around the view.
    ///
    /// The outline fills clockwise from the top based on `progress` (0...1).
    ///
    /// - Parameters:
    ///   - progress: Fill amount from 0.0 to 1.0.
    ///   - radius: Corner radius of the outline.
    ///   - lineWidth: Stroke width.
    ///   - color: Color of the filled portion.
    ///   - trackColor: Color of the unfilled track.
    ///   - visible: Whether the outline is visible.
    func progressOutline(
        progress: CGFloat,
        radius: CGFloat = 12,
        lineWidth: CGFloat = 3,
        color: Color = .accentColor,
        trackColor: Color = .gray.opacity(0.2),
        visible: Bool = true
    ) -> some View {
        modifier(ProgressOutlineModifier(
            progress: progress,
            radius: radius,
            lineWidth: lineWidth,
            color: color,
            trackColor: trackColor,
            visible: visible
        ))
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
#Preview("Progress Outline") {
    struct ProgressOutlineDemo: View {
        @State private var progress: CGFloat = 0.6
        var body: some View {
            VStack(spacing: 32) {
                Text("Upload")
                    .font(.headline)
                    .padding(24)
                    .progressOutline(
                        progress: progress,
                        radius: 12,
                        lineWidth: 3,
                        color: .blue
                    )

                HStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .font(.title)
                        .padding(16)
                        .progressOutline(progress: progress, radius: 20, color: .orange)

                    Image(systemName: "heart.fill")
                        .font(.title)
                        .padding(16)
                        .progressOutline(progress: progress, radius: 20, color: .pink)
                }

                Slider(value: $progress, in: 0...1)
                    .padding(.horizontal, 40)
            }
            .padding()
        }
    }
    return ProgressOutlineDemo()
}
