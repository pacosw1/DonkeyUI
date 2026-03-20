//
//  ShadowModifier.swift
//  DonkeyUI
//
//  Created by Paco Sainz on 3/19/26.
//

import SwiftUI

// MARK: - Elevation

@available(iOS 17.0, macOS 14.0, *)
public enum Elevation: CGFloat, Sendable {
    case none = 0       // no shadow
    case low = 2        // subtle cards
    case medium = 4     // floating cards
    case high = 8       // modals, sheets
    case highest = 16   // popovers
}

// MARK: - Elevation Modifier

@available(iOS 17.0, macOS 14.0, *)
private struct ElevationModifier: ViewModifier {
    let level: Elevation
    let customColor: Color?
    @Environment(\.colorScheme) private var colorScheme

    private var shadowColor: Color {
        if let customColor {
            return customColor
        }
        let opacity = colorScheme == .dark ? 0.5 : 0.15
        return Color.black.opacity(opacity)
    }

    private var shadowRadius: CGFloat {
        level.rawValue
    }

    private var shadowY: CGFloat {
        level.rawValue / 2
    }

    func body(content: Content) -> some View {
        content
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
    }
}

// MARK: - View Extension

@available(iOS 17.0, macOS 14.0, *)
public extension View {

    /// Apply shadow based on elevation level
    func elevation(_ level: Elevation, color: Color? = nil) -> some View {
        modifier(ElevationModifier(level: level, customColor: color))
    }
}
