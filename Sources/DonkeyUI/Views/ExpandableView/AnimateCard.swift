//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 5/20/23.
//

import SwiftUI

struct AnimateCard: View {
    @State private var offsetX = 0.0
    @State private var offsetY = 0.0

    var body: some View {
        VStack {
            HStack {
                Text("Hello")
                Spacer()
            }
        }
        .card()
        .padding()
        .offset(x: offsetX, y: offsetY)
        .animation(.spring().speed(1.1), value: offsetX)
        .onAppear {
            offsetX = 300 // TODO convert to screen width
            offsetY = 500
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                offsetX = 0
                offsetY = 0
            }
        }
    }
}

struct AnimateCard_Previews: PreviewProvider {
    static var previews: some View {
        AnimateCard()
    }
}
