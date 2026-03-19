//
//  BorderModifier.swift
//  Divergent
//
//  Created by paco on 26/11/22.
//
import SwiftUI

public struct BiometricLockModifier: ViewModifier {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var model = BiometricLockModel()
    let enabled: Bool
    
    public func body(content: Content) -> some View {
        content
            .overlay {
                BiometricLockView(model: model)
                    .opacity(enabled && !model.isUnlocked ? 1 : 0)
            }
            .onChange(of: scenePhase) {
                if scenePhase == .background {
                    model.isUnlocked = false
                }
            }
        
      }
}

public extension View {
    func biometricLock(enabled: Bool = true) -> some View {
        modifier(BiometricLockModifier(enabled: enabled))
    }
}
    
