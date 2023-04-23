//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 3/11/23.
//

import SwiftUI

public struct ProgressBarView: View {
    var width: CGFloat = 100.0
    var fullWidth: Bool = false
    var progress: CGFloat
    
    public init(width: CGFloat = 100.0, fullWidth: Bool = false, progress: CGFloat) {
        self.width = width
        self.fullWidth = fullWidth
        self.progress = progress
    }
    
    func getWidth(proxy: GeometryProxy) -> CGFloat {
        if fullWidth {
            return proxy.size.width
        }
        return width
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                HStack {
                    Color.clear
                        .bgOverlay(bgColor: .gray.opacity(0.2), radius: 20)
                        .frame(width: getWidth(proxy: proxy), height: 10)

                }
                HStack() {
                    Color.clear
                        .bgOverlay(bgColor: .blue.opacity(0.8), radius: 20)
                        .frame(width: progress * getWidth(proxy: proxy), height: 10)
                        .animation(.spring(), value: progress)
                    
                }
            }
            .frame(width: getWidth(proxy: proxy), height: 10)
        }
        .frame(height: 10)
        .task {
        }
        
    }
    
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Spacer()
            ProgressBarView(width: 50,  progress: 0.9)
                .padding()
            Spacer()
            
        }
        .padding()
    }
}
