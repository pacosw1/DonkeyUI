//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 5/20/23.
//

import SwiftUI

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

struct TestView: View {
    
    @State var progress : CGFloat = 0
    
    var body: some View {
        
        VStack {
            Text("\(progress)")
            HStack {
                Spacer()
                ProgressIcon(progress: progress / 100.0, icon: "circle.fill", iconSize: 350, shape: Rectangle())
                Spacer()
            }
            Slider(value: $progress, in: 0.0...100.0)
            Button {
                withAnimation() {
                    progress += 10
                }
            } label: {
                Text("Done")
            }

        }
        .padding()
        
        
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
