//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 4/15/23.
//

import SwiftUI

public struct BiometricLockView: View {
        
    @Environment(\.scenePhase) var scenePhase
    @StateObject var model = BiomericLockModel()
    public var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            VStack {
                Text(model.isUnlocked ? "Unlocked": "Locked")
                IconView(image: "lock.shield.fill", color: .primary, size: .veryLarge)
                Text("App Locked")
                    .fontWeight(.heavy)
                    .foregroundColor(.primary)
                    .font(.title2)
                
                
                
                ButtonView(label: "Unlock", icon: "faceid", buttonTyoe: .bordered) {
                    model.authenticate()
                }
                .padding(.top)
            }
        }
        .onChange(of: scenePhase) { (phase) in
                    switch phase {
                    case .active: print("ScenePhase: active")
                    case .background:
                        model.isUnlocked = false
                    case .inactive:
                        model.isUnlocked = false

                    @unknown default:
                        print("default")
                    }
                }
    }
}

struct BiometricLockView_Previews: PreviewProvider {
    static var previews: some View {
        BiometricLockView()
    }
}
