//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 5/20/23.
//

import SwiftUI

public struct ExpandView: View {
    @State var show = false
    
    
    var height: CGFloat {
        return show ? 100 : 45
    }
    
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text("Hello")
            if show {
                Spacer()
            }
        }
        .frame(height: height)
        .padding(.vertical, show ? 20 : 0)
        .contentShape(Rectangle())
        .card()
        .animation(.easeInOut, value: height)
        .onTapGesture {
            withAnimation {
                show.toggle()
            }
        }
    }
}

struct ExpandView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello there")
            ExpandView()
            ExpandView()
            ExpandView()
            ExpandView()

            Text("Nice cock")
        }
    }
}
