//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 6/18/23.
//

import SwiftUI

public struct SlideView: Identifiable {
    public var id = UUID()
    let view: AnyView
    let icon: String
    let title: String
    let color: Color
    
    public init(id: UUID = UUID(), view: some View, icon: String, title: String = "", color: Color = .accentColor) {
        self.id = id
        self.view = AnyView(view)
        self.icon = icon
        self.title = title
        self.color = color
    }
}

public struct OnboardingPanelView: View {
    @State var selectedStep = 1
    @State var offset = 0.0
    @State var opacity = 1
    var views: [SlideView] = [.init(view: InvestingView(), icon: "figure.dress.line.vertical.figure"),
                              .init(view: WeightView(), icon: "scalemass.fill"),
                              .init(view: Text("2"), icon: "circle.fill"),
                              .init(view: Text("2"), icon: "circle.fill"),
                              .init(view: Text("2"), icon: "circle.fill")
    ]
    
    @State var showReview: Bool = false
    
    
    public init(views: [SlideView]) {
        self.selectedStep = 1
        self.offset = 0.0
        self.opacity = 1
        self.views = views
    }
    
    
    
    
    public var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
            
            
            ZStack {
                Color(uiColor: UIColor.secondarySystemBackground)
                    .ignoresSafeArea()
                    

                VStack(alignment: .center) {
       
                    
                    ProgressStepperView(steps: views.count, currentStep: $selectedStep)

                }
                .padding(.horizontal)

            }
            .frame(maxHeight: 80)
//            .frame(height: 80)
        
            
                    VStack(alignment: .leading) {
//                        HStack {
//                            Spacer()
//                            
//                            ProgressIcon(progress: Double(selectedStep) / Double(views.count), icon: views[selectedStep-1].icon, iconSize: 70)
//                                .padding(.top, 30)
//                                .padding(.bottom, 10)
//                            
//                            Spacer()
//                        }
                        HStack(spacing: 0) {
                            
                            
                            
                            ForEach(views) { slide in
                                VStack {
                                  
//                                        .animation(.spring(), value: selectedStep)
                                    
                                
                                   Spacer()
                                    slide.view
                                    Spacer()
                                }

                            }
                            .padding(.horizontal)

                            .frame(width: proxy.size.width)
//                            .bgOverlay(bgColor: .pink)
//                            .offset(x: -proxy.size.width)
                            .offset(x: -Double(selectedStep-1) * proxy.size.width)


//                            .offset(x: CGFloat(selectedStep) * proxy.size.width)
//                            .offset(x:  proxy.size.width)


                        }



                        .animation(.easeInOut, value: selectedStep)

                        
                        HStack {
                            Spacer()
                            ButtonView(label: selectedStep == views.count ? "Review" : "Next", color: .black, padding: 2, fullWidth: true) {
                                withAnimation {
                                    if selectedStep == views.count {
                                        // Perform save to core data
                                        showReview = true
                                        //Show review sheet
                                    } else {
                                        selectedStep = min(selectedStep+1, views.count)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)

//                        .padding()

                        // Content
                    }

//                    .padding(.horizontal, 30)
                    .onChange(of: selectedStep) { _ in
                        
                        
                       
                    }
            }

        }
       
        
    }
}

struct OnboardingPanelView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPanelView(views: [
            .init(view: Text("hi"), icon: "figure.dress.line.vertical.figure"),
            .init(view: Text("bye"), icon: "scalemass.fill")
        ])
    }
}

class OnboardingModel: ObservableObject {
    public static let shared = OnboardingModel()

    @Published var incomeText: String = ""
    @Published var emergencyText: String = ""
    @Published var funText: String = ""
    @Published var debtText: String = ""


    @Published var isIncomeShown: Bool = false
    @Published var isEmergencyShown: Bool = false
    @Published var isFunShown: Bool = false
    @Published var isDebtShown: Bool = false



}



// Views

struct InvestingView: View {
    @State var months = 1
    var body: some View {
        VStack(alignment: .leading) {
            Text("Biological Sex")
                .font(.title)
                .fontWeight(.heavy)
            Text("Helps us determine your water intake needs")
            
            
            
            VStack(alignment: .leading) {
                HStack {
                    ForEach(1..<3) { x in
                        
                        let selected = x == months
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: .infinity, height: 50)
                                .foregroundColor(selected ? .black : .white)
                            Text("\(x * 10)%")
                                .font(.title3)
                                .foregroundColor(selected ? .white : .black)
                                .fontWeight(.heavy)
                        }
                        .bgOverlay(bgColor: .clear, radius: 10, borderColor: selected ? .black : .black)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            months = x
                        }
                        .animation(.interactiveSpring(), value: months)

                    }

                    
                }
            
            }
        }
        .padding(.horizontal)
    }
}



struct WeightView: View {
    @State var months = 1
    @State var weight = "0"
    @State var shown = false
    var body: some View {
        VStack(alignment: .leading) {
            Text("How much do you weigh")
                .font(.title)
                .fontWeight(.heavy)
            Text("We recommend starting with 10% if you have debt")
            
            
            
            VStack(alignment: .leading) {
                HStack {
                    ForEach(1..<5) { x in
                        
                        let selected = x == months
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: .infinity, height: 50)
                                .foregroundColor(selected ? .black : .white)
                            Text("\(x * 10)%")
                                .font(.title3)
                                .foregroundColor(selected ? .white : .black)
                                .fontWeight(.heavy)
                        }
                        .bgOverlay(bgColor: .clear, radius: 10, borderColor: selected ? .black : .black)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            months = x
                        }
                        .animation(.interactiveSpring(), value: months)

                    }

                    
                }
            
            }
        }
        .padding(.horizontal)
//        Mone(text: $weight, onEdit: { _ in
//            shown  = true
//        })
    }
}
