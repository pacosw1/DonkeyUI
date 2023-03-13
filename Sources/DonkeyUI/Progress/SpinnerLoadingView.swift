//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 3/13/23.
//

import SwiftUI




struct SpinnerLoadingView: View {
    var color: Color = .accentColor
    var disabled: Bool = false
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5)
                .opacity(0.3)
                .foregroundColor(.gray)

            Circle()
                .trim(from: 0, to: 0.4)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .foregroundColor(color.opacity(disabled ? 0.5 : 1))
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: isAnimating)
        }
        .frame(width: 25, height: 25)
        .onAppear() {
            self.isAnimating = true
        }
    }
}

struct SpinnerLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            SpinnerLoadingView()
//            SpinnerLoadingView(color: .purple, disabled: false)
        }

    }
}


//
//ZStack {
//            Circle()
//                .stroke(lineWidth: 4)
//                .opacity(0.3)
//                .foregroundColor(.gray)
//
//            Circle()
//                .trim(from: 0, to: 0.4)
//                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
//                .foregroundColor(.blue)
//                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
//                .animation(Animation.linear(duration: 0.8).repeatForever(autoreverses: false))
//        }
//        .frame(width: 60, height: 60)
//        .onAppear() {
//            self.isAnimating = true
//        }
