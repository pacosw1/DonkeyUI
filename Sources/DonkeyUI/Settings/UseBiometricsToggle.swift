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
    
    var biometryType: LABiometryType {
        var error: NSError?
        let context = LAContext()

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        return self.biometryType
    }

    @AppStorage("useBiometrics") var useBiometrics: Bool = false
    public var body: some View {
        if biometryType == .faceID || biometryType == .touchID {
            SettingToggleView(isOn: $useBiometrics, label: "Authentication", systemIcon: biometryType == .touchID ? "touchid" : "faceid", iconColor: .teal)
        }
    }
}

struct UseBiometricsToggle_Previews: PreviewProvider {
    static var previews: some View {
        UseBiometricsToggle()
    }
}
