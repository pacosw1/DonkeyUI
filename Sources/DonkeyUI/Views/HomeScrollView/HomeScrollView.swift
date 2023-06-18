////
////  HomeScrollView.swift
////  Accounted
////
////  Created by Paco Sainz on 5/17/23.
////
//
//import SwiftUI
//
//struct SlideView: Identifiable {
//    var id = UUID()
//    let view: AnyView
//    let icon: String
//    let title: String
//    let color: Color
//    
//    init(id: UUID = UUID(), view: some View, icon: String, title: String = "", color: Color = .accentColor) {
//        self.id = id
//        self.view = AnyView(view)
//        self.icon = icon
//        self.title = title
//        self.color = color
//    }
//}
//
//struct HomeScrollView: View {
//    @State var selectedStep = 0
//    @State var offset = 0.0
//    @State var opacity = 1
//    @State var views: [SlideView] = [
//     
//
//    ]
//    
//    @State var lastDragDistance: CGFloat = 0.0
//    @GestureState private var translation: CGSize = CGSize()
//    
//    @State var showReview: Bool = false
//    @ObservedObject var editMenu = OnboardingModel.shared
//    
//    @ViewBuilder
//    func getView(index: Int) -> some View {
//        switch index {
//        case 0:
//            IncomeView()
//        case 1 :
//            EmergencyFund()
//        case 2:
//            InvestingView()
//        default:
//            InvestingView()
//        }
//    }
//    
//    var body: some View {
//        GeometryReader { proxy in
//            VStack(alignment: .leading) {
//                
//               
//                    VStack(alignment: .leading) {
//                       
//                        
////                        ZStack {
////                            Color(UIColor.secondarySystemBackground)
////                                .ignoresSafeArea()
//                            HStack {
//                                
//                                ForEach(views) { view in
//                                    HStack(spacing: 7) {
//                                        IconView(image: view.icon, color: view.color, size: .verySmall)
//                                        Text(view.title)
//                                            .font(.title)
//                                            .fontWeight(.heavy)
//                                    }
////                                    .card()
//                                }
//                                .frame(width: proxy.size.width)
//                            }
//
//                           
//
//                            .offset(x: (-Double(selectedStep) * proxy.size.width))
//                            .offset(x: self.translation.width  )
//
//                            .animation(.spring(), value: translation)
//
//
////                        }
//                       
//                        .frame( maxHeight: 100)
//
//                        
//                     
//                        LazyHStack(spacing: 0) {
//                            
//                            ForEach(views.indices) { x in
//                                
//                                views[x].view
//                                    .opacity(x == selectedStep ? 1 : 0.2)
//                                    .animation(.default, value: translation)
//
//                            }
//                            .frame(width: proxy.size.width)
//                           
//                        }
//               
//                        
//
//                        .contentShape(Rectangle())
//                        .offset(x: self.translation.width * 1.3)
//
//                        .offset(x: (-Double(selectedStep) * proxy.size.width))
//                        .animation(.interactiveSpring().delay(0), value: translation)
//
//                        .simultaneousGesture(
//                            DragGesture(minimumDistance: 10).updating(self.$translation) { value, state, nigger in
//                                
//                             
//                                    
//                                    state = value.translation
//                            
//                            }
//                            .onEnded { value in
//                                
//                                lastDragDistance = value.translation.width
//                                let hOffset = value.translation.width / proxy.size.width
//         
//                                let hDir = hOffset < 0 ? 1 : 0
//
//                                    if abs(hOffset) < 0.25 {
//                                        withAnimation(.spring()) {
//                                            lastDragDistance = 0
//                                        }
//                                        return
//                                    }
//                                    if hDir == 0 {
//                                        
//                                        selectedStep = max(selectedStep-1, 0)
//                                        
//                                        
//                                    } else {
//                                        selectedStep = min(selectedStep+1, views.count-1)
//                                    }
//                                    
//                                    lastDragDistance = 0
//
//                            }
//                            
//                        )
//                        
//                        HStack {
//                            ForEach(views) { view in
//                                
//                            }
//                        }
//
//                     
//                    }
//            }
//
//        }
//        
//    }
//}
//
//struct HomeScrollView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeScrollView()
//    }
//}
