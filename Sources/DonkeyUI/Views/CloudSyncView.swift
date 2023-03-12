//
//  CloudSyncView.swift
//  BuildUp
//
//  Created by Paco Sainz on 11/12/22.
//

import SwiftUI

public struct CloudSyncView: View {
    @Binding var cloudSync: Bool
    @State var alertShown = false
    
    init(cloudSync: Binding<Bool>, alertShown: Bool = false) {
        _cloudSync = cloudSync
        self.alertShown = alertShown
    }
    

    public var body: some View {
        SettingToggleView(isOn: $cloudSync, label: "iCloud Sync", systemIcon: "cloud.fill", iconColor: .accentColor, caption: "")
        //You may need to restart the app after toggling this option for changes to take effect.
        .onChange(of: cloudSync) { _ in
            
            if FileManager.default.ubiquityIdentityToken != nil {
                
            } else {
               alertShown = true
                cloudSync = false
            }
        }
        .alert(isPresented: $alertShown) {
            Alert(title: Text("Can't turn on iCloud Sync"), message: Text("You are not logged in to your iCloud account"))
        }
    }
}

struct CloudSyncView_Previews: PreviewProvider {
    static var previews: some View {
        CloudSyncView(cloudSync: .constant(false))
    }
}
