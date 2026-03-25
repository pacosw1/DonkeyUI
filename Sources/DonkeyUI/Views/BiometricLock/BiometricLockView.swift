//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 4/15/23.
//

import SwiftUI

public struct BiometricLockView: View {
        
    @ObservedObject var model: BiometricLockModel
    public var body: some View {
        ZStack {
            DonkeyUIDefaults.systemBackground
                .ignoresSafeArea()
            VStack {
                IconView(image: "lock.shield.fill", color: .primary, size: .veryLarge)
                Text("App Locked")
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)
                    .font(.title2)
                
                
                
                ButtonView(label: "Unlock", icon: "faceid", buttonType: .bordered) {
                    model.authenticate()
                }
                .padding(.top)
            }
        }
       
    }
}

struct BiometricLockView_Previews: PreviewProvider {
    static var previews: some View {
        BiometricLockView(model: BiometricLockModel())
    }
}
