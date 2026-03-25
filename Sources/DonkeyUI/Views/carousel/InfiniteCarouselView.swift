//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 5/13/23.
//

import SwiftUI

class CarouselItem: Identifiable {
    
    init(index: Int, view: AnyView, next: Int = 0, prev: Int = 0) {
        self.view = view
        self.index = index
        self.next = next
        self.prev = prev
    }
    let id = UUID()
    var index: Int = 0
    let view: AnyView
    let next: Int
    let prev: Int
}

struct InfiniteCarouselView: View {
    @State private var selectedIndex: Int = 0
    @State private var x = false
    @State private var items: [CarouselItem] = [
        .init(index: 0, view: AnyView(Text("hello")), next: 1, prev: 2),
        .init(index: 1, view: AnyView(Text("No way")), next: 2, prev: 0),
        .init(index: 2, view: AnyView(Text("sheesh")), next: 0, prev: 1)
    ]
    var body: some View {
        VStack {
            Spacer()
            Button {
                x = true
            } label: {
                Text("show")
            }
            Spacer()
            
        }
        .floatingMenuSheet(isPresented: $x) {
            VStack {
                Text("Hello Man")
                HStack {
                    
                    Text("Shees")
                    Button {
                        x = false
                    } label: {
                        Text("Done")
                    }
                    Spacer()
                }
            }
        }

    }
}

struct InfiniteCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        InfiniteCarouselView()
    }
}
