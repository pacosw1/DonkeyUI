//
//  FormNavigationExtension.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/22/22.
//

import SwiftUI

struct FormNavigation: ViewModifier {
    @Environment(\.presentationMode) var presentationMode

    var submitLabel: String
    var submitDisabled: Bool
    var submitAction: () -> Void
    var header: String
    @State var text = ""
    
    func body(content: Content) -> some View {
        NavigationView {
            content
            
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
//                            Image(systemName: "xmark.circle.fill")
//                                .foregroundColor(Color(white: 0.5))
//                                .font(.system(size: 20))
                            
                        }
                        .padding(.top)
                    }
                    ToolbarItem(placement: .principal) {
                        Text(header)
                            .fontWeight(.heavy)
                            .padding(.top)
                    }
                   
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        
                        Button(action: {
                            submitAction()
                            presentationMode.wrappedValue.dismiss()
                            
                        }) {
                            Text(submitLabel).disabled(submitDisabled)
                        }
                        .padding(.top)
                    }
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
