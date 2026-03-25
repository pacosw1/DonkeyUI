//
//  FluidView.swift
//  DonkeyUI
//
//  Generic reusable fluid simulation: fill any shape with realistic sloshing liquid.
//  Uses spring-damper physics, Catmull-Rom spline rendering, accelerometer tilt,
//  and shake detection. Ported from WaterProgress.
//

import SwiftUI
#if os(iOS) || os(watchOS)
import CoreMotion
#endif

// MARK: - Motion Manager

@available(iOS 17.0, macOS 14.0, *)
@MainActor
@Observable
public final class DonkeyMotionManager {
    public var tiltX: Double = 0
    public var tiltY: Double = 0
    public var isShaking: Bool = false
    public var shakeCount: Int = 0

    #if os(iOS) || os(watchOS)
    private let motion = CMMotionManager()
    #endif
    private var lastShakeTime: Date = .distantPast
    private var shakeResetTask: Task<Void, Never>?

    public init() {}

    public func start() {
        #if os(iOS) || os(watchOS)
        guard motion.isAccelerometerAvailable, !motion.isAccelerometerActive else { return }
        motion.accelerometerUpdateInterval = 1.0 / 60.0

        motion.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            self.tiltX = data.acceleration.x
            self.tiltY = data.acceleration.y

            let magnitude = sqrt(
                data.acceleration.x * data.acceleration.x +
                data.acceleration.y * data.acceleration.y +
                data.acceleration.z * data.acceleration.z
            )
            if magnitude > 1.8 {
                let now = Date.now
                if now.timeIntervalSince(self.lastShakeTime) > 0.5 {
                    self.lastShakeTime = now
                    self.isShaking = true
                    self.shakeCount += 1
                    // Reset shake count after 3 seconds of no shaking
                    self.shakeResetTask?.cancel()
                    self.shakeResetTask = Task { @MainActor in
                        try? await Task.sleep(for: .seconds(3))
                        self.shakeCount = 0
                    }
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(600))
                        self.isShaking = false
                    }
                }
            }
        }
        #endif
    }

    public func stop() {
        #if os(iOS) || os(watchOS)
        motion.stopAccelerometerUpdates()
        #endif
    }
}

// MARK: - Fluid Simulation

@available(iOS 17.0, macOS 14.0, *)
@MainActor
@Observable
public final class DonkeyFluidSimulation {
    /// Number of control points along the surface.
    public let pointCount: Int = 16

    /// Height displacement for each control point.
    public var heights: [Double]

    /// Velocity for each control point.
    public var velocities: [Double]

    /// Global surface angle from device tilt.
    public var surfaceAngle: Double = 0

    /// Angular velocity for the surface tilt.
    public var angleVelocity: Double = 0

    // Physics constants
    private let springStiffness: Double = 180
    private let damping: Double = 4.0
    private let spread: Double = 0.15
    private let gravity: Double = 12.0

    public init() {
        heights = Array(repeating: 0, count: 16)
        velocities = Array(repeating: 0, count: 16)
    }

    /// Advance the simulation by one time step.
    public func update(dt: Double, tiltX: Double, isShaking: Bool) {
        let clampedDt = min(dt, 1.0 / 20.0)

        // Spring-damper for global surface angle
        let rawAngle = -atan(tiltX / max(abs(1.0 - abs(tiltX)), 0.01)) * 180 / .pi
        let targetAngle = max(-12, min(12, rawAngle))
        let angleForce = (targetAngle - surfaceAngle) * gravity - angleVelocity * damping
        angleVelocity += angleForce * clampedDt
        surfaceAngle += angleVelocity * clampedDt

        // Shake adds random impulses
        if isShaking {
            for i in 0..<pointCount {
                velocities[i] += Double.random(in: -80...80)
            }
        }

        // Spring physics per point
        for i in 0..<pointCount {
            let force = -springStiffness * heights[i] - damping * 2 * velocities[i]
            velocities[i] += force * clampedDt
            heights[i] += velocities[i] * clampedDt
        }

        // Spread waves between neighbors
        var leftDeltas = Array(repeating: 0.0, count: pointCount)
        var rightDeltas = Array(repeating: 0.0, count: pointCount)

        for _ in 0..<2 {
            for i in 0..<pointCount {
                if i > 0 {
                    leftDeltas[i] = spread * (heights[i] - heights[i - 1])
                    velocities[i - 1] += leftDeltas[i]
                }
                if i < pointCount - 1 {
                    rightDeltas[i] = spread * (heights[i] - heights[i + 1])
                    velocities[i + 1] += rightDeltas[i]
                }
            }
            for i in 0..<pointCount {
                if i > 0 { heights[i - 1] += leftDeltas[i] * clampedDt }
                if i < pointCount - 1 { heights[i + 1] += rightDeltas[i] * clampedDt }
            }
        }
    }
}

// MARK: - Gold Shimmer Overlay

@available(iOS 17.0, macOS 14.0, *)
public struct DonkeyGoldShimmerOverlay: View {
    public let tiltX: Double
    public let tiltY: Double

    public init(tiltX: Double, tiltY: Double) {
        self.tiltX = tiltX
        self.tiltY = tiltY
    }

    public var body: some View {
        Canvas { context, size in
            let centerX = size.width * (0.5 + tiltX * 0.4)
            let centerY = size.height * (0.4 + tiltY * 0.3)
            let radius = max(size.width, size.height) * 0.6

            let gradient = Gradient(colors: [
                Color.white.opacity(0.4),
                Color(red: 1, green: 0.92, blue: 0.5).opacity(0.2),
                Color(red: 1, green: 0.84, blue: 0).opacity(0.08),
                .clear
            ])

            context.fill(
                Path(ellipseIn: CGRect(
                    x: centerX - radius / 2,
                    y: centerY - radius / 2,
                    width: radius,
                    height: radius
                )),
                with: .radialGradient(
                    gradient,
                    center: CGPoint(x: centerX, y: centerY),
                    startRadius: 0,
                    endRadius: radius / 2
                )
            )
        }
    }
}

// MARK: - Fluid Fill View

@available(iOS 17.0, macOS 14.0, *)
public struct FluidFillView: View {
    /// Fill level from 0 (empty) to 1 (full).
    public let fillPercent: Double

    /// Primary liquid color.
    public var color: Color

    /// Whether to use the accelerometer for tilt-based sloshing.
    public var enableMotion: Bool

    /// Size of the icon/shape container.
    public var iconSize: CGFloat

    /// Color to use when fillPercent >= 1.0. Defaults to gold.
    public var completionColor: Color?

    /// Whether to show a checkmark when full.
    public var showCheckmark: Bool

    /// SF Symbol name used as the fill mask. Defaults to "drop.fill".
    public var maskImage: String?

    @State private var motionManager = DonkeyMotionManager()
    @State private var fluid = DonkeyFluidSimulation()
    @State private var lastUpdateTime: Double = 0
    @State private var sloshing = false
    @State private var lastHapticTime: Date = .distantPast
    @Environment(\.scenePhase) private var scenePhase

    public init(
        fillPercent: Double,
        color: Color = .accentColor,
        enableMotion: Bool = true,
        iconSize: CGFloat = 200,
        completionColor: Color? = Color(red: 1.0, green: 0.84, blue: 0.0),
        showCheckmark: Bool = false,
        maskImage: String? = nil
    ) {
        self.fillPercent = fillPercent
        self.color = color
        self.enableMotion = enableMotion
        self.iconSize = iconSize
        self.completionColor = completionColor
        self.showCheckmark = showCheckmark
        self.maskImage = maskImage
    }

    private var clampedFill: CGFloat {
        min(1.0, max(0.0, fillPercent))
    }

    private var isComplete: Bool {
        fillPercent >= 1.0
    }

    private var symbolName: String {
        maskImage ?? "drop.fill"
    }

    @ViewBuilder
    private var maskView: some View {
        Image(systemName: symbolName)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    public var body: some View {
        ZStack {
            // Background shape (faint)
            Image(systemName: symbolName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(color.opacity(0.12))

            // Fluid simulation rendered via Canvas
            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                let now = timeline.date.timeIntervalSinceReferenceDate
                let tiltX = motionManager.tiltX
                let shaking = motionManager.isShaking
                let angle = fluid.surfaceAngle
                let pts = fluid.heights

                Canvas { context, size in
                    let fillColor: Color = isComplete && completionColor != nil
                        ? completionColor!.opacity(0.85)
                        : color.opacity(0.75)

                    drawFluid(
                        in: &context, size: size,
                        fillPercent: clampedFill,
                        surfaceAngle: angle,
                        pointHeights: pts,
                        pointCount: fluid.pointCount,
                        time: now,
                        color: fillColor
                    )
                }
                .onChange(of: now) {
                    let dt = lastUpdateTime > 0 ? now - lastUpdateTime : 1.0 / 60.0
                    lastUpdateTime = now
                    fluid.update(dt: dt, tiltX: tiltX, isShaking: shaking)

                    // Subtle slosh haptic when wave energy is high
                    let maxHeight = fluid.heights.map(abs).max() ?? 0
                    if maxHeight > 5 && Date.now.timeIntervalSince(lastHapticTime) > 0.5 {
                        lastHapticTime = .now
                        sloshing.toggle()
                    }
                }
            }
            .frame(width: iconSize, height: iconSize)
            .mask { maskView }

            // Gold shimmer on completion
            if isComplete && completionColor != nil {
                DonkeyGoldShimmerOverlay(tiltX: motionManager.tiltX, tiltY: motionManager.tiltY)
                    .frame(width: iconSize, height: iconSize)
                    .mask { maskView }
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            // Checkmark
            if isComplete && showCheckmark {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: iconSize * 0.2))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: iconSize, height: iconSize)
        .animation(.bouncy, value: isComplete)
        .onAppear { if enableMotion { motionManager.start() } }
        .onDisappear { motionManager.stop() }
        .onChange(of: scenePhase) {
            if !enableMotion { return }
            if scenePhase == .active { motionManager.start() }
            else { motionManager.stop() }
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: enableMotion ? motionManager.isShaking : false)
        .sensoryFeedback(.impact(weight: .light, intensity: 0.3), trigger: sloshing)
    }

    // MARK: - Fluid Drawing

    /// Draws the fluid surface with Catmull-Rom spline interpolation.
    private func drawFluid(
        in context: inout GraphicsContext,
        size: CGSize,
        fillPercent: CGFloat,
        surfaceAngle: Double,
        pointHeights: [Double],
        pointCount: Int,
        time: Double,
        color: Color
    ) {
        let baseFillY = size.height * (1.0 - fillPercent)
        let angleRad = surfaceAngle * .pi / 180.0
        let centerX = size.width / 2

        var path = Path()
        var surfacePoints: [CGPoint] = []

        for i in 0..<pointCount {
            let xFrac = Double(i) / Double(pointCount - 1)
            let x = xFrac * size.width

            // Tilt contribution: linear slope based on surface angle
            let distFromCenter = x - centerX
            let tiltY = tan(angleRad) * distFromCenter

            // Wave contribution from simulation
            let waveY = pointHeights[i] * 0.4

            // Rolling wave -- gentle sine that moves across surface continuously
            let rollPhase = time * 2.5 + xFrac * .pi * 2
            let rollWave = sin(rollPhase) * size.height * 0.012
            // Second harmonic for organic feel
            let roll2 = sin(rollPhase * 1.7 + 0.5) * size.height * 0.006

            let y = baseFillY + tiltY + waveY + rollWave + roll2
            surfacePoints.append(CGPoint(x: x, y: y))
        }

        guard let first = surfacePoints.first else { return }
        path.move(to: first)

        // Catmull-Rom to Bezier for smooth curves
        for i in 0..<surfacePoints.count - 1 {
            let p0 = i > 0 ? surfacePoints[i - 1] : surfacePoints[i]
            let p1 = surfacePoints[i]
            let p2 = surfacePoints[i + 1]
            let p3 = i + 2 < surfacePoints.count ? surfacePoints[i + 2] : surfacePoints[i + 1]

            let cp1x = p1.x + (p2.x - p0.x) / 6
            let cp1y = p1.y + (p2.y - p0.y) / 6
            let cp2x = p2.x - (p3.x - p1.x) / 6
            let cp2y = p2.y - (p3.y - p1.y) / 6

            path.addCurve(
                to: p2,
                control1: CGPoint(x: cp1x, y: cp1y),
                control2: CGPoint(x: cp2x, y: cp2y)
            )
        }

        // Close well past the bottom to prevent tilt gaps
        path.addLine(to: CGPoint(x: size.width, y: size.height + 50))
        path.addLine(to: CGPoint(x: 0, y: size.height + 50))
        path.closeSubpath()

        context.fill(path, with: .color(color))
    }
}

// MARK: - Fluid Fill Modifier

@available(iOS 17.0, macOS 14.0, *)
private struct FluidFillModifier: ViewModifier {
    let fillPercent: Double
    let color: Color
    let enableMotion: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geo in
                    FluidFillView(
                        fillPercent: fillPercent,
                        color: color,
                        enableMotion: enableMotion,
                        iconSize: min(geo.size.width, geo.size.height)
                    )
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
    }
}

@available(iOS 17.0, macOS 14.0, *)
public extension View {
    /// Overlays a fluid fill effect on this view.
    ///
    /// The fluid simulation responds to device tilt and shake, with natural
    /// sloshing behavior powered by spring-damper physics.
    ///
    /// - Parameters:
    ///   - fillPercent: Fill level from 0.0 (empty) to 1.0 (full).
    ///   - color: The liquid color.
    ///   - enableMotion: Whether to use accelerometer for tilt response.
    func fluidFill(
        fillPercent: Double,
        color: Color = .accentColor,
        enableMotion: Bool = true
    ) -> some View {
        modifier(FluidFillModifier(
            fillPercent: fillPercent,
            color: color,
            enableMotion: enableMotion
        ))
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
#Preview("Fluid Fill") {
    struct FluidDemo: View {
        @State private var fill: Double = 0.5
        var body: some View {
            VStack(spacing: 32) {
                FluidFillView(
                    fillPercent: fill,
                    color: .blue,
                    enableMotion: false,
                    iconSize: 200,
                    showCheckmark: fill >= 1.0,
                    maskImage: "drop.fill"
                )

                VStack(spacing: 8) {
                    Text("\(Int(fill * 100))%")
                        .font(.title.bold())
                    Slider(value: $fill, in: 0...1)
                        .padding(.horizontal, 40)
                }

                HStack(spacing: 16) {
                    FluidFillView(
                        fillPercent: fill,
                        color: .orange,
                        enableMotion: false,
                        iconSize: 80,
                        maskImage: "heart.fill"
                    )
                    FluidFillView(
                        fillPercent: fill,
                        color: .green,
                        enableMotion: false,
                        iconSize: 80,
                        maskImage: "star.fill"
                    )
                    FluidFillView(
                        fillPercent: fill,
                        color: .purple,
                        enableMotion: false,
                        iconSize: 80,
                        maskImage: "cup.and.saucer.fill"
                    )
                }
            }
            .padding()
        }
    }
    return FluidDemo()
}
