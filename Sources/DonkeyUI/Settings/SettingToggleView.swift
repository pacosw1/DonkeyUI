//
//  SettingToggleView.swift
//  BuildUp
//
//  Created by paco on 05/11/22.
//

import SwiftUI

public struct SettingToggleView: View {
    @Binding var isOn: Bool
    let label: String
    var systemIcon: String
    var iconColor: Color
    var caption: String = ""
    
    public init(isOn: Binding<Bool>, label: String, systemIcon: String, iconColor: Color, caption: String = "") {
        _isOn = isOn
        self.label = label
        self.systemIcon = systemIcon
        self.iconColor = iconColor
        self.caption = caption
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $isOn, label: {
                
            
                HStack {
                    IconView(image: systemIcon, color: iconColor, size: .tiny)
                    Text(label)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                }

            })
            if caption != "" {
                Text(caption)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
            }
        }.onChange(of: isOn) { newVal in
            
            if newVal {
//                play(sound: "SwitchAOn.aif")
            } else {
//                play(sound: "SwitchAOff.aif")

            }
        }
       
    }
}

struct SettingToggleView_Previews: PreviewProvider {
    static var previews: some View {
        
        SettingToggleView(isOn: .constant(false), label: "Test", systemIcon: "xmark", iconColor: .blue, caption: "Automatically rollover uncompleted tasks to the following day")
                .preferredColorScheme(.dark)
        
    }
}
