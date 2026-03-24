//
//  AnimationPresets.swift
//  DonkeyUI
//
//  Created by Paco Sainz on 3/19/26.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
public extension Animation {

    /// Quick spring for UI feedback (0.3s)
    static var quickSpring: Animation {
        .spring(duration: 0.3, bounce: 0.2)
    }

    /// Smooth spring for page transitions (0.5s)
    static var smoothSpring: Animation {
        .spring(duration: 0.5, bounce: 0.1)
    }

    /// Bouncy spring for playful interactions (0.6s)
    static var bouncySpring: Animation {
        .spring(duration: 0.6, bounce: 0.35)
    }

    /// Subtle ease for small changes (0.2s)
    static var subtle: Animation {
        .easeInOut(duration: 0.2)
    }

    /// Snappy for toggles and switches (0.15s)
    static var snappy: Animation {
        .easeOut(duration: 0.15)
    }

    /// Gentle reveal for onboarding content (0.8s)
    static var gentleReveal: Animation {
        .easeInOut(duration: 0.8)
    }

    /// Content slide for onboarding cards (0.5s spring)
    static var contentSlide: Animation {
        .spring(duration: 0.5, bounce: 0.15)
    }
}
