//
//  CustomTabModifier.swift
//  BuildUp
//
//  Created by Paco Sainz on 11/6/22.
//

import SwiftUI

struct CustomTabModifier: ViewModifier {
    func body(content: Content) -> some View {
           content
        }
}

extension View {
    func customTabItem() -> some View {
        modifier(CustomTabModifier())
    }
}

//struct CustomTabView: View {
//    @State var selected = 0
//}

//struct CustomTabModifier_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}
