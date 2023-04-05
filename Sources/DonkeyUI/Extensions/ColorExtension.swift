//
//  ColorExtension.swift
//  BuildUp
//
//  Created by Paco Sainz on 11/13/22.
//

import Foundation
import UIKit
import SwiftUI


public extension Color {

    init?(hex: String) {
            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

            var rgb: UInt64 = 0

            var r: CGFloat = 0.0
            var g: CGFloat = 0.0
            var b: CGFloat = 0.0
            var a: CGFloat = 1.0

            let length = hexSanitized.count

            guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

            if length == 6 {
                r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
                g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
                b = CGFloat(rgb & 0x0000FF) / 255.0

            } else if length == 8 {
                r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
                g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
                b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
                a = CGFloat(rgb & 0x000000FF) / 255.0

            } else {
                return nil
            }

            self.init(red: r, green: g, blue: b, opacity: a)
        }
    
    

        func buttonText(darkMode: Bool) -> Color {
            return Color(UIColor(self).lighter(componentDelta: darkMode ? 0 : 0.98))
        }
    
        func buttonBackground() -> Color {
            return Color(UIColor(self).lighter(componentDelta: 0.05)).opacity(0.3)
        }
 
        func toHex() -> String? {
            let uic = UIColor(self)
            guard let components = uic.cgColor.components, components.count >= 3 else {
                return nil
            }
            let r = Float(components[0])
            let g = Float(components[1])
            let b = Float(components[2])
            var a = Float(1.0)

            if components.count >= 4 {
                a = Float(components[3])
            }

            if a != Float(1.0) {
                return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
            } else {
                return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
            }
        }

}

public extension UIColor {
    
  
    
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
           return max(0, min(1, toComponent + value))
       }
    
    private func makeColor(componentDelta: CGFloat) -> UIColor {
            var red: CGFloat = 0
            var blue: CGFloat = 0
            var green: CGFloat = 0
            var alpha: CGFloat = 0
            
            // Extract r,g,b,a components from the
            // current UIColor
            getRed(
                &red,
                green: &green,
                blue: &blue,
                alpha: &alpha
            )
            
            // Create a new UIColor modifying each component
            // by componentDelta, making the new UIColor either
            // lighter or darker.
            return UIColor(
                red: add(componentDelta, toComponent: red),
                green: add(componentDelta, toComponent: green),
                blue: add(componentDelta, toComponent: blue),
                alpha: alpha
            )
        }
    
    func lighter(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: componentDelta)
    }
    
    func darker(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: -1*componentDelta)
    }
}
