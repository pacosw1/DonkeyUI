////
////  SwiftUIView.swift
////  
////
////  Created by Paco Sainz on 4/6/23.
////
//import SwiftUI
//
//struct CustomList: View {
//    let values: [any Identifiable] = []
//    
//    var body: some View {
//        ScrollView {
//            LazyVStack(alignment: .leading, spacing: 1) {
//                ForEach(values) { value in
//                    RowView {
//                        
//                    } action: {
//                        
//                    }
//                }
//            }
//        }
//    }
//}
//struct CustomList_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomList {
//            ForEach(1..<50) { item in
//                RowView {
//                    Text("\(item)")
//                } action: {
//                    print("hi")
//                }
//            }
//        }
//    }
//}
