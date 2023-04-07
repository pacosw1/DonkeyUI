//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 4/5/23.
//



import SwiftUI

struct ContentOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct PullSearch: View {
    @State var pulledUp = false
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Pulled up: \(pulledUp ? "true": "false")")
                List {
                    ForEach(0..<100) { item in
                        Text("Item \(item)")
                            .frame(height: 50)
                            .background(GeometryReader { proxy in
                                Color.clear.preference(key: ContentOffsetKey.self, value: proxy.frame(in: .named("list")).origin.y)
                            })
                    }
                }
                .coordinateSpace(name: "list")
                .onPreferenceChange(ContentOffsetKey.self) { value in
                    let maxScrollOffset = max(geometry.size.height + 50 * 100, 0) // 50 is row height, 100 is the number of items
                    if value > maxScrollOffset {
                        print("List pulled all the way up")
                        pulledUp = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            pulledUp = false
                        }
                    }
                }
                
            }
        }
    }
}

struct PullSearch_Previews: PreviewProvider {
    static var previews: some View {
        PullSearch()
    }
}
