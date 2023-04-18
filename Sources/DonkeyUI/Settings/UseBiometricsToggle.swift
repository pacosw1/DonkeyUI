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
    
    var hasBiometric: Bool {
        var error: NSError?
        let context = LAContext()

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }

        return context.biometryType != .none
    }
    
    @AppStorage("useBiometrics") var useBiometrics: Bool = false
    public var body: some View {
        if hasBiometric {
            SettingToggleView(isOn: $useBiometrics, label: "Authentication", systemIcon: "faceid", iconColor: .teal)
        }
          

    }
}

struct UseBiometricsToggle_Previews: PreviewProvider {
    static var previews: some View {
        UseBiometricsToggle()
    }
}
