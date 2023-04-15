//
//  BorderModifier.swift
//  Divergent
//
//  Created by paco on 26/11/22.
//
import SwiftUI

public struct BiometricLockModifier: ViewModifier {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var model = BiomericLockModel()
    let enabled: Bool
    
    public func body(content: Content) -> some View {
        VStack {
            if enabled && !model.isUnlocked {
                BiometricLockView(model: model)
            } else {
                content
            }
        }
        .onChange(of: scenePhase) { (phase) in
                    switch phase {
                    case .active: print("ScenePhase: active")

                    case .background:
                        print("background: active")

                        model.isUnlocked = false
                    case .inactive:
                        print("inactive: active")

                    @unknown default:
                        print("default")
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
    
