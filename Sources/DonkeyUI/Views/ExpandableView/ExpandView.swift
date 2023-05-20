//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 5/20/23.
//

import SwiftUI

public struct ExpandView<CustomView>: ViewModifier where CustomView: View {
    @State var show: Bool = false
    @State var height: CGFloat = 0.0
    @State var contentHeight: CGFloat = 0.0

    let customView: () -> CustomView
    

    public func body(content: Content) -> some View {
        VStack(alignment: .leading) {
                content
                    .height(height: $contentHeight)
                customView()
                .height(height: $height)
                .opacity(show ? 1 : 0)
        }
        .frame(height: show ? height : contentHeight, alignment: .top)
//        .padding()
        .clipped()
        .frame(maxWidth: .infinity)
        .transition(.move(edge: .bottom))
        .card()
//        .background(Color.gray.cornerRadius(10.0))
        .onTapGesture {
            withAnimation(.spring()) {
                show.toggle()
            }
        }
//        .card(color: show ? Color(UIColor.secondarySystemBackground) : .gray)
       
    }
}

extension View {
    public func expandable<CustomView>(expanded: Bool, @ViewBuilder customView: @escaping () -> CustomView) -> some View where CustomView: View {
        modifier(ExpandView(show: expanded, customView: customView))
    }
}


struct ExpandView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack {
                                HStack {
                Text("Hello there")
                
                                    Spacer()
                                }
                
            }
                    .expandable(expanded: true, customView: {
                            HStack {
                                Text("Option 1")
                                Text("Option 2")
                                Text("Option 3")
                            }
                            .padding(.top)
                         
                        
                        
                    })
                
                
                Text("Nice cock")
            
        }
    }
}
