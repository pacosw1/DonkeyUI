//
//  Optional.swift
//  BuildUp
//
//  Created by paco on 07/11/22.
//

import Foundation

public extension Optional where Wrapped == NSSet {
    func array<T: Hashable>(of: T.Type) -> [T] {
        if let set = self as? NSSet, let typed = set as? Set<T> {
            return Array(typed)
        }
        return [T]()
    }
}
