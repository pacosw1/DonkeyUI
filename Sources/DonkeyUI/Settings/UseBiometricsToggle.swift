//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 4/16/23.
//

import SwiftUI
import LocalAuthentication

public struct UseBiometricsToggle: View {
    public init() {}
    
    @State var biometricType: LABiometryType = .none

    @AppStorage("useBiometrics") var useBiometrics: Bool = false
    public var body: some View {
            if biometricType == .faceID || biometricType == .touchID {
                SettingToggleView(isOn: $useBiometrics, label: "Authentication", systemIcon: biometricType == .touchID ? "touchid" : "faceid", iconColor: .teal)
            } else {
                EmptyView()
                    .task {
                        var error: NSError?
                        let context = LAContext()

                        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                            biometricType = context.biometryType
                        } else {
                            biometricType = .none

                        }

                    }
            }
        
    }
}

struct UseBiometricsToggle_Previews: PreviewProvider {
    static var previews: some View {
        UseBiometricsToggle()
    }
}
