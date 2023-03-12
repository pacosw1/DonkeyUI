//
//  LocaleExtension.swift
//  Divergent
//
//  Created by Paco Sainz on 1/6/23.
//

import Foundation

extension Locale {
    static var is24Hour: Bool {
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
        return dateFormat.firstIndex(of: "a") == nil
    }
}
