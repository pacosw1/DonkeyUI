//
//  BorderModifier.swift
//  Divergent
//
//  Created by paco on 26/11/22.
//
import SwiftUI

public struct BiometricLockModifier: ViewModifier {
    @StateObject var model = BiomericLockModel()
    let enabled: Bool
    
    public func body(content: Content) -> some View {
        if !model.isUnlocked {
            BiometricLockView()
        } else {
            content
        }
        
      }
}

public extension View {
    func biometricLock(enabled: Bool = true) -> some View {
        modifier(BiometricLockModifier(enabled: enabled))
    }
}
    
