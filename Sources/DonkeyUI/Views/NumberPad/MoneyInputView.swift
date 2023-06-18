//
//  MoneyInputView.swift
//  Accounted
//
//  Created by Paco Sainz on 5/16/23.
//

import SwiftUI

class KeypadController: ObservableObject {
    public static let shared = KeypadController()

    @Published var focusedText: Binding<String> = .constant("")
    @Published var showKeypad: Bool = false
}


struct MoneyInputView: View {
    @Binding var text: String
    var isEditing: Bool = false
    var onDelete: () -> Void = {}
    var onEdit: (Binding<String>) -> Void = {_ in}
    @ObservedObject var keypad = KeypadController.shared
    
    
    @Environment(\.colorScheme) var mode
    
    var buttonColor: Color {
        return mode == .dark ? .gray : .black
    }
    
    
    var body: some View {
        HStack(spacing: 4) {
//            Text("$")
//                .fontWeight(.heavy)
//                .font(.largeTitle)
//                .foregroundColor(.gray)
            Text(text == "" ? "0" : text)
                .font(.largeTitle)
                .fontWeight(.heavy)
            Spacer()
            Button {
                if !isEditing {
                    keypad.showKeypad = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                        keypad.focusedText = $text
                    }
                    onEdit($text)
                } else {
                    onDelete()
                }
            } label: {
                if !isEditing {
                    IconView(image: "square.and.pencil", color: buttonColor, size: .small)
                } else {
                    IconView(image: "delete.backward.fill", color: .gray, size: .small)
                }
            }
        }
        .card()
    }
}

struct MoneyInputView_Previews: PreviewProvider {
    static var previews: some View {
        MoneyInputView(text: .constant("1000"), onDelete: {})
    }
}
