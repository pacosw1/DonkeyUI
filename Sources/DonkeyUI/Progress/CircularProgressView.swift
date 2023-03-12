//
//  CircularProgressView.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/16/22.
//

import SwiftUI

public struct CircularProgressView: View {
    var color: Color = .blue
    var delay: Double = 0.0
    let progress: CGFloat
    let size: CGFloat
    
    @Environment(\.colorScheme) var colorScheme
    
    var complete: Bool {
        return progress == 1
    }

    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)

    public var body: some View {
            ZStack {
                Circle()
                // 1
                    .stroke(
                       Color(UIColor(color).lighter(componentDelta: 0.05)) ,
                        lineWidth: size / 5
                    )
                    .frame(width: size * 1.2 * 2, height: size * 1.2 * 2)
//                    .opacity(complete ? 1 - progress : 1)
//                    .scaleEffect(complete ? 2 : 1)
                    .animation(.spring(), value: complete)
//                Circle()
//                // 1
//                    .stroke(
//                        complete ? .green : .clear,
//                        lineWidth: complete ? 0: 20
//                    )
//                    .frame(width: size * 1.2 * 2)
//                    .opacity(complete ? 1 - progress : 1)
//                    .scaleEffect(complete ? 2 : 1)
//                    .animation(.easeInOut, value: complete)
//
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    
                    .stroke(Color(UIColor(color).lighter(componentDelta: 0.05))
                            , lineWidth: size)
                    .frame(width: size, height: size)
//                    .opacity(complete ? 0: 1)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring()
                        .delay(delay),
                               value: progress)
                    .overlay {

                        Image(systemName: "checkmark")
                            .opacity(progress == 1 ? 1: 0.0001)
                            .foregroundColor(Color(UIColor(color).lighter(componentDelta: 0.5)))
                            .fontWeight(.heavy)
                            .font(.system(size: size / 1.4))
                            .animation(.easeInOut.delay(0.2), value: progress)
                            .scaleEffect(complete ? 1 : 0.001)
                    }
            }
        }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack {
            CircularProgressView(progress: 1, size: 50)
                .preferredColorScheme(.dark)
            
        }
    }
}
