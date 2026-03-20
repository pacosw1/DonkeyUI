//
//  SparkleView.swift
//  DonkeyUI
//
//  Looping sparkle effect using Canvas with 4-pointed star drawing
//  and sine-wave phase animation. Ported from WaterProgress.
//

import SwiftUI

// MARK: - Sparkle Config

public struct SparkleConfig: Sendable {
    public let x: Double
    public let y: Double
    public let size: Double
    public let color: Color
    public let period: Double
    public let phaseOffset: Double
}

// MARK: - Sparkle View

@available(iOS 17.0, macOS 14.0, *)
public struct DonkeySparkleView: View {
    public let isActive: Bool
    public var centerX: CGFloat
    public var centerY: CGFloat
    public var radius: CGFloat
    public var colors: [Color]

    private let sparkleCount = 24

    @State private var items: [SparkleConfig] = []

    public init(
        isActive: Bool,
        centerX: CGFloat = 0,
        centerY: CGFloat = 0,
        radius: CGFloat = 90,
        colors: [Color] = [.yellow, .orange, Color(red: 1, green: 0.84, blue: 0), .white]
    ) {
        self.isActive = isActive
        self.centerX = centerX
        self.centerY = centerY
        self.radius = radius
        self.colors = colors
    }

    public var body: some View {
        if isActive {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    for item in items {
                        // Each sparkle loops on its own phase within the cycle
                        let phase = (now / item.period + item.phaseOffset)
                            .truncatingRemainder(dividingBy: 1.0)

                        // Smooth pulse: sine curve for natural grow/shrink
                        let scale = sin(phase * .pi)
                        guard scale > 0.01 else { continue }

                        var ctx = context
                        ctx.opacity = Double(scale) * 0.85
                        ctx.translateBy(x: item.x, y: item.y)

                        let s = item.size * scale

                        // 4-pointed star
                        let star = Path { p in
                            p.move(to: CGPoint(x: 0, y: -s))
                            p.addLine(to: CGPoint(x: s * 0.3, y: -s * 0.3))
                            p.addLine(to: CGPoint(x: s, y: 0))
                            p.addLine(to: CGPoint(x: s * 0.3, y: s * 0.3))
                            p.addLine(to: CGPoint(x: 0, y: s))
                            p.addLine(to: CGPoint(x: -s * 0.3, y: s * 0.3))
                            p.addLine(to: CGPoint(x: -s, y: 0))
                            p.addLine(to: CGPoint(x: -s * 0.3, y: -s * 0.3))
                            p.closeSubpath()
                        }
                        ctx.fill(star, with: .color(item.color))
                    }
                }
            }
            .allowsHitTesting(false)
            .onAppear { generateItems() }
        }
    }

    private func generateItems() {
        guard items.isEmpty else { return }
        items = (0..<sparkleCount).map { _ in
            SparkleConfig(
                x: centerX + .random(in: -radius...radius),
                y: centerY + .random(in: -radius...radius),
                size: .random(in: 5...14),
                color: colors.randomElement()!,
                period: .random(in: 1.2...2.5),
                phaseOffset: .random(in: 0...1)
            )
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
#Preview("Sparkle") {
    ZStack {
        Color.black.ignoresSafeArea()
        DonkeySparkleView(
            isActive: true,
            centerX: 200,
            centerY: 400,
            radius: 120
        )
    }
}
