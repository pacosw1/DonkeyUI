//
//  FormNavigationExtension.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/22/22.
//

import SwiftUI

struct FormNavigation: ViewModifier {
    @Environment(\.dismiss) var dismiss

    var submitLabel: String
    var submitDisabled: Bool
    var submitAction: () -> Void
    var header: String
    @State private var text = ""
    
    func body(content: Content) -> some View {
        NavigationStack {
            content
            
                .toolbar {
                    #if !os(macOS)
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                        }
                        .padding(.top)
                    }
                    #else
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                        }
                        .padding(.top)
                    }
                    #endif
                    ToolbarItem(placement: .principal) {
                        Text(header)
                            .fontWeight(.heavy)
                            .padding(.top)
                    }
                    #if !os(macOS)
                    ToolbarItem(placement: .keyboard) {
                        HStack {

                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {

                        Button(action: {
                            submitAction()
                            dismiss()

                        }) {
                            Text(submitLabel).disabled(submitDisabled)
                        }
                        .padding(.top)
                    }
                    #else
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            submitAction()
                            dismiss()

                        }) {
                            Text(submitLabel).disabled(submitDisabled)
                        }
                        .padding(.top)
                    }
                    #endif
                }
                .fullscreen()
        }
    }
}


extension View {
    func sheetNavigation( header: String, submitLabel: String, submitDisabled: Bool, submitAction: @escaping () -> Void) -> some View {
        modifier(FormNavigation(submitLabel: submitLabel, submitDisabled: submitDisabled, submitAction: submitAction, header: header))
    }
}

struct FormNavigation_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello")
            .sheetNavigation(header: "Hello", submitLabel: "Done", submitDisabled: true, submitAction: {
            })
    }
}
