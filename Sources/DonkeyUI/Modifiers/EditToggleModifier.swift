//
//  EditToggleView.swift
//  BuildUp
//
//  Created by paco on 04/11/22.
//

import SwiftUI

public struct EditToggleView: ViewModifier {
    @Binding var isOn: Bool

    let systemImage: String
    let label: String
    let secondaryLabel: String
    let iconColor: Color
    let startExpanded: Bool
    @State var isOpen: Bool
    @State var firstOpen: Bool = true
    
    
    public init(isOn: Binding<Bool>, systemImage: String, label: String, secondaryLabel: String, iconColor: Color, startExpanded: Bool) {
        _isOn = isOn
        self.systemImage = systemImage
        self.label = label
        self.secondaryLabel = secondaryLabel
        self.iconColor = iconColor
        self.startExpanded = startExpanded
        self.isOpen = startExpanded
    }
    
    
    public func body(content: Content) -> some View {
        VStack(alignment: .leading) {

            Toggle(isOn: $isOn ,label:  {
                HStack {
                    IconView(image: systemImage, color: iconColor, size: .verySmall)
                
                    
                    VStack(alignment: .leading) {
                        Text(label)
                            .font(.body)
                        if isOn && !secondaryLabel.isEmpty {
                            Text(secondaryLabel)
                                .font(.caption)
                                .foregroundColor(.accentColor)
                        }
                        
                    }
                    .animation(.spring(), value: isOn)
                    Spacer()
                }
                .frame(minHeight: 35)
                .contentShape(Rectangle())
                .onTapGesture {
                    if isOn {
                        isOpen.toggle()
                    }
                }
               
            })
           
            
            .onChange(of: isOn, perform: {
                _ in
                isOpen = isOn
                
            })
            
            
            if isOpen {
                VStack(alignment: .leading) {
                    content
                        .animation(.easeInOut.delay(isOpen ? 0 : 0), value: isOpen)
                }
            }
            
        }
        .animation(!isOpen ? .none : .spring(), value: isOpen)
      
//        .padding(.vertical, 10)
//        .padding(.horizontal)
//        .card()
        
    }
}

extension View {
    public func editToggle(isOn: Binding<Bool>, startExpanded: Bool = false,systemImage: String, label: String, iconColor: Color, secondaryLabel: String = "") -> some View {
        modifier(EditToggleView(isOn: isOn, systemImage: systemImage, label: label, secondaryLabel: secondaryLabel, iconColor: iconColor, startExpanded: startExpanded))
    }
}

