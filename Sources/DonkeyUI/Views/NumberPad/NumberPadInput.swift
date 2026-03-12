//
//  MoneyInput.swift
//  Accounted
//
//  Created by Paco Sainz on 5/16/23.
//

import SwiftUI

struct ButtonItem: Identifiable {
    var id = UUID()
    let value: String
    
}

public struct NumberPadInput: View {
    @Binding var label: String
    var submitAction: (Double) -> Void
    var showInput: Bool = true
    
    var numValue: Double {
        return Double(label) ?? 0
    }
    
    var enterDisabled: Bool {
        if label.last != nil && label.last == "." {
            return true
        }
        
        if label == "" {
            return true
        }
        
        if label.count > 10 {
            return true
        }
        
        return false
    }
    
    
    var numDisabled: Bool {
        let chars = label.components(separatedBy: ".")
        
        if chars.count > 1 && chars[1].count == 2 {
            return true
        }
        return false
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    public init(label: Binding<String>, submitAction: @escaping (Double) -> Void) {
        _label = label
        self.submitAction = submitAction
    }

    public var body: some View {
        
        
        VStack(alignment: .leading) {
            if showInput {
                MoneyInputView(text: $label, isEditing: true, onDelete: {
                    if label.count == 0 {
                        return
                    }
                    label.removeLast()
                })
                
                
                .padding(.bottom, 30)
            }
            
            
            Grid(horizontalSpacing: 12, verticalSpacing: 10) {
                GridRow {
                    PadButton(display: "1") {
                        label += "1"
                    }
                    .disabled(numDisabled)
                    PadButton(display: "2") {
                        label += "2"
                    }
                    .disabled(numDisabled)

                    PadButton(display: "3") {
                        label += "3"
                    }
                    .disabled(numDisabled)

                }
                GridRow {
                    PadButton(display: "4") {
                        label += "4"
                    }
                    .disabled(numDisabled)

                    PadButton(display: "5") {
                        label += "5"
                    }
                    .disabled(numDisabled)

                    PadButton(display: "6") {
                        label += "6"
                    }
                    .disabled(numDisabled)

                }
                GridRow {
                    PadButton(display: "7") {
                        label += "7"
                    }
                    .disabled(numDisabled)

                    PadButton(display: "8") {
                        label += "8"
                    }
                    .disabled(numDisabled)

                    PadButton(display: "9") {
                        label += "9"
                    }
                    .disabled(numDisabled)

                }
                GridRow {
                    PadButton(display: ".") {
                        label += "."
                    }
                    .disabled(label.count == 0 || label.contains("."))
                    PadButton(display: "0") {
                        label += "0"
                    }
                    .disabled(numDisabled)

                    Button {
                        submitAction(numValue)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 13)
                                .frame(width: .infinity, height: 70)
                            Image(systemName: "checkmark.square.fill")
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                .font(.title)
                        }
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .disabled(enterDisabled)
                }
            }
        }
    }
}


struct PadButton: View {
    let display: String
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var buttonColor: Color {
        #if canImport(UIKit)
        return colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.secondarySystemBackground)
        #else
        return colorScheme == .dark ? Color(NSColor.controlBackgroundColor) : Color(NSColor.controlBackgroundColor)
        #endif
    }
    var body: some View {
        Button {
            action()
        } label: {
            
            
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .frame(width: .infinity, height: 70)
                    .foregroundColor(buttonColor)
                Text(display)
                    .font(.title)
                    .foregroundColor(.primary)
                    .fontWeight(.semibold)
                    .card()
            }
        }
    }
}

struct MoneyInput_Previews: PreviewProvider {
    static var previews: some View {
        NumberPadInput(label: .constant("100"), submitAction: {_ in})
            .padding()
    }
}
