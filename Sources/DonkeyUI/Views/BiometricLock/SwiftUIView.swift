//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 4/16/23.
//

import SwiftUI

struct UseBiometricsToggle: View {
    @AppStorage("useBiometrics") var useBiometrics: Bool = false
    var body: some View {
        SettingToggleView(isOn: $useBiometrics, label: "Authentication", systemIcon: "faceid", iconColor: .teal)

    }
}

struct UseBiometricsToggle_Previews: PreviewProvider {
    static var previews: some View {
        UseBiometricsToggle()
    }
}
