//
//  RippleAnimation.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/24/22.
//

import SwiftUI

extension Animation {
    static func ripple(index: Int) -> Animation {
        Animation.spring(dampingFraction: 0.5)
            .speed(2)
            .delay(0.03 * Double(index))
    }
}
