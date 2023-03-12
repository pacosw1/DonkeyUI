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
    public var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $isOn, label: {
                
            
                HStack {
                    IconView(image: systemIcon, color: iconColor, size: .small)
                    Text(label)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                }

            })
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .bordered()
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
        
        StatefulPreviewWrapper(true) { val in
            SettingToggleView(isOn: val, label: "monka", systemIcon: "xmark", iconColor: .blue, caption: "Automatically rollover uncompleted tasks to the following day")
//                .card()
                .preferredColorScheme(.dark)
        }
    }
}
