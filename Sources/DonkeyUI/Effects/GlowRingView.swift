//
//  GlowRingView.swift
//  DonkeyUI
//
//  RadialGradient glow with pulse animation when active.
//  Ported from WaterProgress.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
public struct DonkeyGlowRingView: View {
    public let isActive: Bool
    public var size: CGFloat
    public var color: Color

    @State private var glowOpacity = 0.0
    @State private var glowScale = 0.8

    public init(
        isActive: Bool,
        size: CGFloat = 240,
        color: Color = .yellow
    ) {
        self.isActive = isActive
        self.size = size
        self.color = color
    }

    public var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(0.4), color.opacity(0.1), .clear],
                    center: .center,
                    startRadius: size * 0.21,
                    endRadius: size * 0.5
                )
            )
            .frame(width: size, height: size)
            .scaleEffect(glowScale)
            .opacity(glowOpacity)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    withAnimation(.easeIn(duration: 0.5)) {
                        glowOpacity = 1.0
                        glowScale = 1.0
                    }
                    // Pulse
                    withAnimation(
                        .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(0.5)
                    ) {
                        glowScale = 1.1
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.3)) {
                        glowOpacity = 0
                        glowScale = 0.8
                    }
                }
            }
    }
}

// MARK: - Preview

@available(iOS 17.0, macOS 14.0, *)
#Preview("Glow Ring") {
    struct GlowDemo: View {
        @State private var active = false
        var body: some View {
            VStack(spacing: 40) {
                DonkeyGlowRingView(isActive: active, color: .yellow)
                Button(active ? "Deactivate" : "Activate") {
                    active.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    return GlowDemo()
}
