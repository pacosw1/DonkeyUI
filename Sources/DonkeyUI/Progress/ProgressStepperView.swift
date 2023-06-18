//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 6/18/23.


import SwiftUI

public struct ProgressStepperView: View {
    let steps: Int
    @Binding var currentStep: Int
    
    var lineHeight: CGFloat = 5
    var color: Color
    
    var progressAmount: Double {
        return Double(currentStep) / (Double(steps))
    }
    
    func progressSize(width: CGFloat) -> CGFloat {
        return ((width-(30)) / CGFloat(steps-1)) * CGFloat(currentStep-1)
    }
    
    
    func selected(step: Int) -> Bool {
        return currentStep == step
    }
    
    
    public init(steps: Int, currentStep: Binding<Int>, lineHeight: CGFloat = 5, color: Color = .accentColor) {
        self.steps = steps
        _currentStep = currentStep
        self.lineHeight = lineHeight
        self.color = color
    }
    
    public var body: some View {
        VStack(alignment: .center) {
            GeometryReader { proxy in
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: proxy.size.width, height: lineHeight)
                        .foregroundColor(.gray.opacity(0.2))
                                        
                    Rectangle()
                        .frame(width: progressSize(width: proxy.size.width), height: lineHeight)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 100), value: currentStep)
                        .foregroundColor(color.opacity(0.8))
                        .offset(x: 30/2)
                    
                    
                    
                    
                        
                    HStack(alignment: .center, spacing: 0) {
                        
                        ForEach(1..<steps+1) { x in
                            ZStack {
                                
                                let isSelected = selected(step: x)
                                Circle()
                                    .fill(currentStep >= x ? color : .gray)
                                    .animation(.spring().delay(0), value: currentStep)
                                
                                    .frame(width: 30)
                                   
                                    .animation(.spring().delay(0), value: currentStep)

                                Circle()
                                    .frame(width: 30 - 5)
                                    .foregroundColor(.white)
                                    .opacity(isSelected ? 1 : 0)
                                    .animation(.easeIn.delay(0), value: currentStep)
                                

                                Text("\(x)")
                                    .font(.headline)
                                    .fontWeight(.heavy)
                                    .foregroundColor(selected(step: x) ? color : .white)
                                    .animation(.easeIn.delay(0), value: currentStep)
                            }
                            
                            if x < steps {
                                Spacer()
                            }
                        }
                    }
                    
                }
                
                
                //            .frame(width: proxy.size.width)
                //            .padding()
               
            }
        }
        .padding()

        
    }
}

struct ProgressStepperView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProgressStepperView(steps: 5, currentStep: .constant(4))
            .padding(50)
    }
}
