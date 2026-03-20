//
//  ViewExtensions.swift
//  DonkeyUI
//
//  Created by Paco Sainz on 3/19/26.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Size Preference Key

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - View Extensions

@available(iOS 17.0, macOS 14.0, *)
public extension View {

    /// Apply modifier only when condition is true
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apply modifier only when optional has value
    @ViewBuilder
    func ifLet<T, Transform: View>(_ value: T?, transform: (Self, T) -> Transform) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }

    /// Dismiss keyboard
    func dismissKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }

    /// Debug border (red outline + background color name)
    func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
        #if DEBUG
        self
            .border(color, width: width)
            .overlay(alignment: .topLeading) {
                Text("\(String(describing: color))")
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(color)
            }
        #else
        self
        #endif
    }

    /// Apply disabled + reduced opacity together
    func disabledWithOpacity(_ disabled: Bool, opacity: Double = 0.5) -> some View {
        self
            .disabled(disabled)
            .opacity(disabled ? opacity : 1.0)
    }

    /// Read view size into a closure
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        self
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geometry.size)
                }
            }
            .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }

    /// Hide view completely (removes from layout, unlike opacity)
    @ViewBuilder
    func isHidden(_ hidden: Bool, removeCompletely: Bool = false) -> some View {
        if hidden {
            if removeCompletely {
                EmptyView()
            } else {
                self.hidden()
            }
        } else {
            self
        }
    }
}
