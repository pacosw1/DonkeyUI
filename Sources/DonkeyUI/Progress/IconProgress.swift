//
//  WaveFormView.swift
//  PromoDoc
//
//  Created by Paco Sainz on 5/4/23.
//

import SwiftUI

public struct ProgressIcon: View {
    public init(progress: CGFloat, animationStart: CGFloat = 0, icon: String = "trophy.fill", iconSize: CGFloat = 40) {
        self.progress = progress
        self.animationStart = animationStart
        self.icon = icon
        self.iconSize = iconSize
    }
    
    var progress: CGFloat
    @State var animationStart: CGFloat = 0
    
    var icon: String = "trophy.fill"
    var iconSize: CGFloat = 40
    public var body: some View {
        VStack {
            GeometryReader { proxy in
                ZStack {
                    Image(systemName: icon)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray.opacity(0.15))
                        .animation(.spring(), value: progress)

                    WaterWave(progress: progress, offset: animationStart)
                        .fill(gradientColor(color: .yellow))
                        .frame(width: iconSize, height: iconSize, alignment: .center)

                        .mask {
                            Image(systemName: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)

                        }
                }
                .animation(.spring(), value: progress)
                .frame(width: iconSize, height: iconSize, alignment: .center)
            }
        }
        .frame(width: iconSize, height: iconSize)
    }
}

private func gradientColor(color: Color) -> LinearGradient {
    let colors: [Color] = [color.opacity(0.5), color.opacity(0.7), color.opacity(0.89), color.opacity(0.95), color.opacity(1)]

       return LinearGradient(gradient: Gradient(colors: colors), startPoint: .bottom, endPoint: .top)
   }

struct ProgressIcon_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 30){
            ProgressIcon(progress: 0.3, icon: "drop.fill", iconSize: 50)
            ProgressIcon(progress: 0.5, icon: "circle.fill", iconSize: 50)
            ProgressIcon(progress: 0.3, iconSize: 50)

        }
        .padding(.horizontal)
        .padding()
    }
}


struct WaterWave: Shape {
    var progress: CGFloat
    var waveHeight: CGFloat {
        return 0.1
    }
    
    var offset: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
           AnimatablePair(offset, progress)
        }

        set {
            progress = (newValue.second)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: .zero)
            
            let progressHeight: CGFloat = (1 - progress) * rect.height
            let height: CGFloat = waveHeight * rect.height
            
            for value in stride(from: 0, through: rect.width, by: 2) {
                let x: CGFloat = value
                let sine: CGFloat = sin(Angle(degrees: value + offset).radians)
                let y: CGFloat = progressHeight + (height * sine)
                
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))

        }
    }
}
