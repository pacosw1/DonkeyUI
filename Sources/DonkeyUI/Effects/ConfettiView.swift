//
//  ConfettiView.swift
//  DonkeyUI
//
//  Reusable confetti particle system using Canvas + TimelineView.
//  Ported from WaterProgress.
//

import SwiftUI

// MARK: - Confetti Particle

public struct ConfettiParticle: Sendable {
    public let startX: Double
    public let startY: Double
    public let velocityX: Double
    public let velocityY: Double
    public let rotation: Double
    public let rotationSpeed: Double
    public let size: Double
    public let aspectRatio: Double
    public let color: Color
    public let lifetime: Double
    public let createdAt: Double
}

// MARK: - Confetti View

@available(iOS 17.0, macOS 14.0, *)
public struct DonkeyConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    public let colors: [Color]
    public let particleCount: Int

    public init(
        colors: [Color] = [.blue, .cyan, .yellow, .orange, .pink, .green, .purple, .mint],
        particleCount: Int = 80
    ) {
        self.colors = colors
        self.particleCount = particleCount
    }

    public var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                for particle in particles {
                    let age = now - particle.createdAt
                    guard age < particle.lifetime else { continue }

                    let progress = age / particle.lifetime
                    let opacity = 1.0 - progress
                    let x = particle.startX + particle.velocityX * age
                    let y = particle.startY + particle.velocityY * age + 200 * age * age // gravity
                    let rotation = particle.rotation + particle.rotationSpeed * age

                    var contextCopy = context
                    contextCopy.opacity = opacity
                    contextCopy.translateBy(x: x, y: y)
                    contextCopy.rotate(by: .degrees(rotation))

                    let rect = CGRect(
                        x: -particle.size / 2,
                        y: -particle.size / 2,
                        width: particle.size,
                        height: particle.size * particle.aspectRatio
                    )
                    contextCopy.fill(Path(rect), with: .color(particle.color))
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    public func fire(in size: CGSize) {
        let now = Date.now.timeIntervalSinceReferenceDate
        var newParticles: [ConfettiParticle] = []

        let screenWidth = size.width
        let screenHeight = size.height

        for _ in 0..<particleCount {
            newParticles.append(ConfettiParticle(
                startX: screenWidth / 2 + .random(in: -50...50),
                startY: screenHeight * 0.3,
                velocityX: .random(in: -200...200),
                velocityY: .random(in: -600 ... -200),
                rotation: .random(in: 0...360),
                rotationSpeed: .random(in: -400...400),
                size: .random(in: 4...10),
                aspectRatio: .random(in: 0.5...2.0),
                color: colors.randomElement()!,
                lifetime: .random(in: 1.5...3.0),
                createdAt: now
            ))
        }
        particles = newParticles
    }
}

// MARK: - Confetti Modifier

@available(iOS 17.0, macOS 14.0, *)
private struct ConfettiModifier: ViewModifier {
    let trigger: Bool
    let colors: [Color]
    @State private var confettiView = DonkeyConfettiView()

    init(trigger: Bool, colors: [Color]) {
        self.trigger = trigger
        self.colors = colors
        self._confettiView = State(initialValue: DonkeyConfettiView(colors: colors))
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    confettiView
                        .onChange(of: trigger) { _, newValue in
                            if newValue {
                                confettiView.fire(in: geometry.size)
                            }
                        }
                }
            }
    }
}

@available(iOS 17.0, macOS 14.0, *)
public extension View {
    /// Overlays a confetti effect that fires whenever `trigger` changes to `true`.
    func confetti(
        trigger: Bool,
        colors: [Color] = [.blue, .cyan, .yellow, .orange, .pink, .green, .purple, .mint]
    ) -> some View {
        modifier(ConfettiModifier(trigger: trigger, colors: colors))
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
#Preview("Confetti") {
    struct ConfettiDemo: View {
        @State private var showConfetti = false
        var body: some View {
            VStack(spacing: 24) {
                Text("Tap to celebrate!")
                    .font(.title2)

                Button("Fire Confetti") {
                    showConfetti.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
            .confetti(trigger: showConfetti)
        }
    }
    return ConfettiDemo()
}
