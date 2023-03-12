////
////  DifficultyCircleView.swift
////  BuildUp
////
////  Created by Paco Sainz on 10/25/22.
////
//
//import SwiftUI
//
//struct DifficultyBarView: View {
//    
//    let difficulty: Difficulty
//
//    let width: CGFloat = 5
//    let height: CGFloat = 5
//    let radius: CGFloat = 2
//    
//    var diff: Color {
//        switch difficulty {
//        case .zero:
//            return .clear.opacity(0.8)
//        case .low:
//            return .green.opacity(0.8)
//        case .med:
//            return .orange.opacity(0.8)
//        case .high:
//            return .pink.opacity(0.8)
//        }
//    }
//    
//    var body: some View {
//            HStack(spacing: 2) {
//                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(.gray.opacity(0.3))
//                    .frame(width: width, height: height)
//                
//                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(.gray.opacity(0.3))
//                    .frame(width: width, height: height)
//                
//                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(.gray.opacity(0.3))
//                    .frame(width: width, height: height)
////                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(.gray.opacity(0.3))
////                    .frame(width: width, height: height)
//                
//                //            .overlay(
//                //                RoundedRectangle(cornerRadius: 20)
//                //                    .stroke(.blue,
//                //                            lineWidth: 10)
//                //            )
//                
//            }
//            .overlay {
//                HStack(spacing: 2) {
//                    RoundedRectangle(cornerRadius: radius, style: .continuous).fill(difficulty.rawValue >= 1 ? diff : .clear)
//                        .frame(width: width, height: height)
//                    
//                    RoundedRectangle(cornerRadius: radius, style: .continuous).fill(difficulty.rawValue >= 2 ? diff : .clear)
//                        .frame(width: width, height: height)
//                    
//                    RoundedRectangle(cornerRadius: radius, style: .continuous).fill(difficulty.rawValue >= 3 ? diff : .clear)
//                        .frame(width: width, height: height)
////                    RoundedRectangle(cornerRadius: radius, style: .continuous).fill(difficulty.rawValue >= 3 ? diff : .clear)
////                        .frame(width: width, height: height)
//                }
//            }
//           
//        
//    }
//}
//
//struct DifficultyCircleView_Previews: PreviewProvider {
//    static var previews: some View {
//        DifficultyBarView(difficulty: .high)
//    }
//}
