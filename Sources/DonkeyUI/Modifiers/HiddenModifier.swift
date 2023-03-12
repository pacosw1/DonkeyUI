//
//  HiddenModifier.swift
//  BuildUp
//
//  Created by paco on 30/08/22.
//

import SwiftUI

struct HiddenModifier: ViewModifier {
    var hidden: Bool
    func body(content: Content) -> some View {
            if hidden {
                EmptyView()
                    .transition(.offset(y: -200))
            } else {
                content
                    .transition(.offset(y: 0))
            }
        }
}

extension View {
    func hidden(_ hidden: Bool = false) -> some View {
        modifier(HiddenModifier(hidden: hidden))
    }
}

struct HiddenModifier_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack {
            Text("Nothing under me")
            Text("Im hidden")
                .hidden(true)
            Text("I shouldnt be hidden")
                .hidden(false)
        }
    }
}
