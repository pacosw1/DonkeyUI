//
//  editScreenModifier.swift
//  BuildUp
//
//  Created by paco on 07/11/22.
//

import Foundation
import SwiftUI

//struct EditScreenModifier: ViewModifier {
//    @Binding var isPresented: Bool
//    var selected: TodoTask?
//    
//    @State var path: [TodoTask] = []
//    func body(content: Content) -> some View {
//           content
//            .sheet(isPresented: $isPresented) {
//                if #available(iOS 16.0, *) {
//                    NavigationStack {
//                        EditItemView(task: selected!, isPresented: $isPresented)
//                    }
//                } else {
//                    NavigationView {
//                        EditItemView(task: selected!, isPresented: $isPresented)
//                    }
//                }
//    
//            }
//        }
//}
//
//extension View {
//    func editScreen(isPresented: Binding<Bool>, selected: TodoTask?) -> some View {
//        modifier(EditScreenModifier(isPresented: isPresented, selected: selected))
//    }
//}
