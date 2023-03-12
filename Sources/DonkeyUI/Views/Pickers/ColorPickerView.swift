////
////  ColorPickerView.swift
////  Divergent
////
////  Created by paco on 02/12/22.
////
//
//import SwiftUI
//import WrappingHStack
//
//
//struct ColorPickerItem: View {
//    
//    let color: Color
//    let selected: Bool
//    var body: some View {
//        ZStack {
//            Circle()
//                .stroke(!selected ? .clear : Color(UIColor.tertiaryLabel).opacity(0.8), lineWidth: 4)
//                .frame(height: 50)
//            Circle()
//                .fill(color)
//                .frame(height: 40)
//                .overlay {
////                    if selected {
////                        Circle()
////                            .fill(Color.accentColor.opacity(0.2))
////                    }
//
//                }
//
//        }
//
//
//
//    }
//}
//
//struct ColorPickerView: View {
//
//    var colors: [Color] = [
//        .pink,
//        .orange,
//        .blue,
//        .red,
//        .teal,
//        .indigo,
//        .green,
//    ]
//    @Binding var selected: Color
//    var body: some View {
//       WrappingHStack(colors, id: \.self, spacing: .constant(15), lineSpacing: 15) { color in
//                ColorPickerItem(color: color, selected: color == selected)
//               .onTapGesture {
//                   selected = color
//               }
//               .animation(.none, value: selected)
//       }
//        .padding()
//        .bordered()
//    }
//}
//
//struct ColorPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ColorPickerView(selected: .constant(.blue))
//        .padding()
//    }
//}
