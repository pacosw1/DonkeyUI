//
//  WaveFormView.swift
//  PromoDoc
//
//  Created by Paco Sainz on 5/4/23.
//

import SwiftUI

public struct ProgressIcon: View {
    public init(progress: CGFloat, icon: String = "trophy.fill", iconSize: CGFloat = 40, color: Color = .black) {
        self.progress = progress
        self.icon = icon
        self.iconSize = iconSize
        self.offset = .zero
        self.color = color
    }
    
    var progress: CGFloat = 0.5
    @State var offset: Angle = .degrees(0)
    
    var icon: String = "trophy.fill"
    var iconSize: CGFloat = 200
    @State var height: CGFloat = 0.0
    let color: Color
    
    public var body: some View {
        VStack {
            GeometryReader { proxy in
                ZStack {
                    Image(systemName: icon)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray.opacity(0.15))
                        .height(height: $height)
                    

                    Wave(offset: offset, percent: 1)
                            .fill(color)
                            .offset(y: iconSize)
                        //                            .frame(height: 500)
                        //                            .offset(y: 100 * progress)
                            .animation(.spring(), value: progress)
                            .offset(y: -progress * iconSize)
                            .clipShape((Circle()).scale(0.9))
                    
                }
              
                .frame(width: iconSize, height: iconSize, alignment: .center)
                .onAppear {
                    withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                           self.offset = Angle(degrees: 360)
                    }
                }
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
            Spacer()
//            ProgressIcon(progress: 0.3, icon: "drop.fill", iconSize: 50)
            ProgressIcon(progress: 0.5, icon: "circle.fill", iconSize: 300)
            Spacer()
//            ProgressIcon(progress: 0.3, iconSize: 50)

        }
//        .padding(.horizontal)
//        .padding()
    }
}

struct Wave: Shape {

    var offset: Angle
    var percent: Double
    
    var animatableData: CGFloat {
        get { offset.degrees }
        set {
            offset.degrees = newValue
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()

        // empirically determined values for wave to be seen
        // at 0 and 100 percent
        let lowfudge = 0.02
        let highfudge = 0.98
        
        let newpercent = lowfudge + (highfudge - lowfudge) * percent
        let waveHeight = 0.02 * rect.height
        let yoffset = CGFloat(1 - newpercent) * (rect.height - 4 * waveHeight) + 2 * waveHeight
        let startAngle = offset
        let endAngle = offset + Angle(degrees: 360)
        
        p.move(to: CGPoint(x: 0, y: yoffset + waveHeight * CGFloat(sin(offset.radians))))
        
        for angle in stride(from: startAngle.degrees, through: endAngle.degrees, by: 5) {
            let x = CGFloat((angle - startAngle.degrees) / 360) * rect.width
            p.addLine(to: CGPoint(x: x, y: yoffset + waveHeight * CGFloat(sin(Angle(degrees: angle).radians))))
        }
        
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        
        return p
    }
}


