//
//  BindingExtensions.swift
//  DonkeyUI
//
//  Created by Paco Sainz on 3/19/26.
//

import SwiftUI

// MARK: - Binding

@available(iOS 17.0, macOS 14.0, *)
public extension Binding {

    /// Transform bound value: $color.map(get: { $0.description }, set: { Color($0) })
    func map<T>(get: @escaping (Value) -> T, set: @escaping (T) -> Value) -> Binding<T> {
        Binding<T>(
            get: { get(self.wrappedValue) },
            set: { self.wrappedValue = set($0) }
        )
    }

    /// Convert Binding<Optional<T>> to Binding<T> with a default fallback
    static func unwrap(_ binding: Binding<Value?>, default defaultValue: Value) -> Binding<Value> where Value: Equatable {
        Binding(
            get: { binding.wrappedValue ?? defaultValue },
            set: { binding.wrappedValue = $0 }
        )
    }
}

// MARK: - Binding<Bool>

@available(iOS 17.0, macOS 14.0, *)
public extension Binding where Value == Bool {

    /// Negate: $isHidden.toggled -> shows when isHidden is false
    var toggled: Binding<Bool> {
        Binding(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}
