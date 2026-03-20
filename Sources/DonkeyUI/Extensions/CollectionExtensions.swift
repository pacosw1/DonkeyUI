//
//  CollectionExtensions.swift
//  DonkeyUI
//
//  Created by Paco Sainz on 3/19/26.
//

import Foundation

// MARK: - Collection

@available(iOS 17.0, macOS 14.0, *)
public extension Collection {

    /// Safe subscript — returns nil instead of crashing on out-of-bounds
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Array

@available(iOS 17.0, macOS 14.0, *)
public extension Array {

    /// Split into chunks: [1,2,3,4,5].chunked(2) -> [[1,2],[3,4],[5]]
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Sequence (Hashable)

@available(iOS 17.0, macOS 14.0, *)
public extension Sequence where Element: Hashable {

    /// Remove duplicates preserving order
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

// MARK: - Array (Identifiable)

@available(iOS 17.0, macOS 14.0, *)
public extension Array where Element: Identifiable {

    /// Remove duplicates by ID preserving order
    func uniquedByID() -> [Element] {
        var seen = Set<AnyHashable>()
        return filter { seen.insert(AnyHashable($0.id)).inserted }
    }
}
