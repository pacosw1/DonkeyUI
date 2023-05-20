//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 5/20/23.
//

import SwiftUI

public struct ExpandView<CustomView>: ViewModifier where CustomView: View {
    @Binding var show: Bool
    @State var height: CGFloat = 0.0
    let customView: () -> CustomView
    

    public func body(content: Content) -> some View {
        VStack(alignment: .leading) {
                content
                customView()
                    .height(height: $height)
                    .opacity(show ? 1 : 0)
                    .animation(show ? .spring().delay(0.2) : .spring().speed(3), value: show)
                    .frame(height: show ? height : 0)

            
        }
        .contentShape(Rectangle())
        .card(color: show ? Color(UIColor.secondarySystemBackground) : .clear)
        .animation(.spring(), value: height)
        .onTapGesture {
            withAnimation {
                if !show {
                    show = true
                }
            }
        }
    }
}

extension View {
    public func expandable<CustomView>(open: Binding<Bool>, @ViewBuilder customView: @escaping () -> CustomView) -> some View where CustomView: View {
        modifier(ExpandView(show: open, customView: customView))
    }
}


struct ExpandView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello there")
                .expandable(open: .constant(true), customView: {
                        VStack {
                            HStack {
                                Text("Option 1")
                                Text("Option 2")
                                Text("Option 3")
                            }
                            Text("Sheesh")
                            Text("Option 1")
                            Text("Option 1")
                            Text("Option 1")
                        }
                    
                })
          

            Text("Nice cock")
        }
    }
}
