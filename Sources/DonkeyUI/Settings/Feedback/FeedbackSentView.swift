//
//  FeedbackSentView.swift
//  Divergent
//
//  Created by paco on 13/12/22.
//

import SwiftUI

struct FeedbackSentView: View {
    var action: () -> Void = {}
    let color: Color = .blue
    var body: some View {
        VStack {
            Spacer()
                IconView(image: "arrow.up.forward.square.fill", color: .blue)
            HStack(alignment: .center) {
                Spacer()
             
                VStack(alignment: .center) {
                    Text("Thank you for your feedback")
                        .font(.headline)
                        .fontWeight(.heavy)
                    Text("Its vital to improve the app")
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
            }
            Spacer()
            
            ButtonView(label: "Submit more feedback", buttonType: .bordered, padding: 2.5) {
                action()
            }
            Spacer()
        }
        .ignoresSafeArea(.keyboard)
        .navigationTitle("")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct FeedbackSentView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackSentView()
    }
}
