//
//  File.swift
//  
//
//  Created by Paco Sainz on 4/4/23.
//

import Foundation
import SwiftUI


public extension Double {
    
    var balanceString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current // Use the user's current locale for the currency symbol

        if let formattedString = formatter.string(from: NSNumber(value: self)) {
            return formattedString
        }
        return "0.00"
    }
    
    var balanceColor: Color {
        return self > 0 ? .green.opacity(0.8) : .pink.opacity(0.8)
    }
    
    var percentageLabel: String {
        return String(format: "%.2f", self)
    }
    
    var balanceStringWithSign: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current // Use the user's current locale for the currency symbol

        if let formattedNumber = formatter.string(from: NSNumber(value: abs(self))) {
            let sign = (self >= 0) ? "+" : "-"
            let formattedString = sign + formattedNumber
            return formattedString // Output: "- $250.00" (if using US English locale)
        }
        return "$0.00"
    }
    
    var balanceStringWithSignIfNegative: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current // Use the user's current locale for the currency symbol

        if let formattedNumber = formatter.string(from: NSNumber(value: abs(self))) {
            let sign = (self >= 0) ? "" : "-"
            let formattedString = sign + formattedNumber
            return formattedString // Output: "- $250.00" (if using US English locale)
        }
        return "$0.00"
    }
}
