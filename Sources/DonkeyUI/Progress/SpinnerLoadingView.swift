//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 3/13/23.
//
import SwiftUI

public struct SpinnerLoadingView: View {
    public init(color: Color = .accentColor, disabled: Bool = false, size: CGFloat = 25, lineWidth: CGFloat = 5) {
        self.color = color
        self.size = size
        self.disabled = disabled
        self.lineWidth = lineWidth
    }
    
    var color: Color
    var disabled: Bool
    var size: CGFloat
    var lineWidth: CGFloat
    @State private var isAnimating = false
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundColor(.gray)

            Circle()
                .trim(from: 0, to: 0.4)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(color.opacity(disabled ? 0.5 : 1))
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: isAnimating)
        }
        .frame(width: size, height: size)
        .onAppear() {
            self.isAnimating = true
        }
    }
}

struct SpinnerLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 30) {
            SpinnerLoadingView(size: 40, lineWidth: 10)
            SpinnerLoadingView(color: .pink)
            SpinnerLoadingView(color: .orange)
            SpinnerLoadingView(color: .green)

        }

    }
}
