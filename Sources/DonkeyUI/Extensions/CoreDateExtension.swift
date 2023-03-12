//
//  CoreDateExtension.swift
//  BuildUp
//
//  Created by Paco Sainz on 11/14/22.
//

import Foundation
import CoreData

extension NSManagedObject {
    func addObject(value: NSManagedObject, forKey key: String) {
        let items = self.mutableSetValue(forKey: key)
        items.add(value)
    }

    func removeObject(value: NSManagedObject, forKey key: String) {
        let items = self.mutableSetValue(forKey: key)
        items.remove(value)
    }
}
