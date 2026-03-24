import SwiftUI

#if canImport(UIKit)
import CoreHaptics
#endif

/// Standalone test view to debug Core Haptics on device.
/// Add this to any app: `HapticTestView()`
public struct HapticTestView: View {
    @State private var log: [String] = []
    @State private var isPlaying = false

    #if canImport(UIKit)
    @State private var engine: CHHapticEngine?
    @State private var player: CHHapticAdvancedPatternPlayer?
    #endif

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Haptic Debug")
                    .font(.largeTitle).bold()

                // Test 1: Basic UIKit haptic
                Button("Test UIImpactFeedbackGenerator") {
                    addLog("Firing UIImpactFeedbackGenerator.light()...")
                    DonkeyHaptics.light()
                    addLog("Done")
                }
                .buttonStyle(.borderedProminent)

                // Test 2: Core Haptics single event
                Button("Test Core Haptics Single Tick") {
                    testSingleCoreHaptic()
                }
                .buttonStyle(.borderedProminent)

                // Test 3: Core Haptics looping pattern
                Button(isPlaying ? "Stop Looping Pattern" : "Start Looping Pattern") {
                    if isPlaying {
                        stopPattern()
                    } else {
                        startPattern()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(isPlaying ? .red : .green)

                // Test 4: Full typing engine
                Button("Test TypingSoundEngine (3 sec)") {
                    testTypingSoundEngine()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

                Divider()

                // Log output
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(log.enumerated()), id: \.offset) { _, entry in
                        Text(entry)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
    }

    private func addLog(_ msg: String) {
        log.append("[\(log.count)] \(msg)")
    }

    private func testSingleCoreHaptic() {
        #if canImport(UIKit)
        addLog("CHHapticEngine.capabilitiesForHardware().supportsHaptics = \(CHHapticEngine.capabilitiesForHardware().supportsHaptics)")

        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            addLog("ERROR: Device does not support haptics")
            return
        }

        do {
            let eng = try CHHapticEngine()
            try eng.start()
            addLog("Engine started OK")

            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let p = try eng.makePlayer(with: pattern)
            try p.start(atTime: CHHapticTimeImmediate)
            addLog("Single tick fired at intensity 1.0")
        } catch {
            addLog("ERROR: \(error.localizedDescription)")
        }
        #else
        addLog("UIKit not available")
        #endif
    }

    private func startPattern() {
        #if canImport(UIKit)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            addLog("ERROR: No haptics support")
            return
        }

        do {
            let eng = try CHHapticEngine()
            eng.isAutoShutdownEnabled = false
            try eng.start()
            self.engine = eng
            addLog("Engine started, autoShutdown disabled")

            // Build pattern: 50 ticks at 60ms intervals
            var events: [CHHapticEvent] = []
            for i in 0..<50 {
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                    ],
                    relativeTime: TimeInterval(i) * 0.06
                ))
            }
            addLog("Created \(events.count) events")

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let p = try eng.makeAdvancedPlayer(with: pattern)
            p.loopEnabled = true
            p.loopEnd = 50.0 * 0.06
            self.player = p
            addLog("Advanced player created, loopEnabled=true, loopEnd=\(p.loopEnd)")

            try p.start(atTime: CHHapticTimeImmediate)
            isPlaying = true
            addLog("Pattern started!")
        } catch {
            addLog("ERROR: \(error.localizedDescription)")
        }
        #endif
    }

    private func stopPattern() {
        #if canImport(UIKit)
        do {
            try player?.stop(atTime: CHHapticTimeImmediate)
            isPlaying = false
            addLog("Pattern stopped")
        } catch {
            addLog("ERROR stopping: \(error.localizedDescription)")
        }
        #endif
    }

    private func testTypingSoundEngine() {
        addLog("Creating TypingSoundEngine(.hapticOnly)...")
        Task { @MainActor in
            let eng = TypingSoundEngine(style: .hapticOnly)
            addLog("Starting sound + haptics...")
            eng.start()

            // Simulate 3 seconds of typewriter
            for i in 0..<60 {
                try? await Task.sleep(for: .milliseconds(50))
                if i % 10 == 0 {
                    addLog("Tick \(i)...")
                }
            }

            eng.stop()
            addLog("Done — did you feel haptics + hear sound?")
        }
    }
}

#Preview("Haptic Test") {
    HapticTestView()
}
