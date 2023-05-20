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
    
    @State var isExpanded = false
    @State var subviewHeight : CGFloat = 0
    
    var body: some View {
        VStack {
            Text("Headline")
            VStack {
                Text("More Info")
                Text("And more")
                Text("And more")
                Text("And more")
                Text("And more")
                Text("And more")
            }
            .height(height: $subviewHeight)
        }
       
        .frame(height: isExpanded ? subviewHeight + 20 : 50, alignment: .top)
        .padding()
        .clipped()
        .frame(maxWidth: .infinity)
        .transition(.move(edge: .trailing))
        .background(Color.gray.cornerRadius(10.0))
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
