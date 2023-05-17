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
    
    
    @State var progress: CGFloat = 0.0
    @State var animationStart: CGFloat = 0
    
    var icon: String = "trophy.fill"
    var iconSize: CGFloat = 40
    public var body: some View {
        VStack {
            GeometryReader { proxy in
                let size = proxy.size
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

                .onAppear {
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                        animationStart = size.width
                    }
                }
                
                Button {
                    progress += 0.2

                } label: {
                    Text("nice")
                }
                
                
            }
            
            

        }
//        .padding()
//        .frame()

//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        .frame(width: iconSize, height: iconSize)


//        .background(Color.gray)
    }
}

private func gradientColor(color: Color) -> LinearGradient {
    let colors: [Color] = [color.opacity(0.5), color.opacity(0.7), color.opacity(0.89), color.opacity(0.95), color.opacity(1)]
//       let stops = stride(from: 0.0, to: 1.0, by: 1.0 / Double(colors.count)).map { $0 }
       return LinearGradient(gradient: Gradient(colors: colors), startPoint: .bottom, endPoint: .top)
   }

struct ProgressIcon_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Spacer()
            ProgressIcon(progress: 0.3, iconSize: 100)
            Spacer()
        }
        .padding(.horizontal)
        .padding()
//            .bgOverlay(bgColor: .blue)
//            WaveFormView(progress: 0.3)
//            WaveFormView(progress: 0.3)

    }
}


struct WaterWave: Shape {
    var progress: CGFloat
    var waveHeight: CGFloat {
        return 0.3
    }
    
    var offset: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
           AnimatablePair(offset, progress)
        }

        set {
//            offset = (newValue.first)
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
