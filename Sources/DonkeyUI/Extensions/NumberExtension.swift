//
//  File.swift
//  
//
//  Created by Paco Sainz on 4/4/23.
//

import Foundation
import SwiftUI


private let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale.current
    return formatter
}()

public extension Double {

    private func formatted(value: Double) -> String? {
        currencyFormatter.string(from: NSNumber(value: value))
    }

    var balanceString: String {
        formatted(value: self) ?? "0.00"
    }

    var balanceColor: Color {
        return self > 0 ? .green.opacity(0.8) : .pink.opacity(0.8)
    }

    var percentageLabel: String {
        return String(format: "%.2f", self) + "%"
    }

    var balanceStringWithSign: String {
        guard let amount = formatted(value: abs(self)) else { return "$0.00" }
        let sign = (self >= 0) ? "+" : "-"
        return sign + amount
    }

    var balanceStringWithSignIfNegative: String {
        guard let amount = formatted(value: abs(self)) else { return "$0.00" }
        let sign = (self >= 0) ? "" : "-"
        return sign + amount
    }
}
