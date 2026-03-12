//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 4/6/23.
//

import SwiftUI

struct RowView<Content: View>: View {
    let action: () -> Void
    @State private var isHighlighted = false
    
    let content: Content

    init(@ViewBuilder content: () -> Content, action: @escaping () -> Void) {
        self.content = content()
        self.action = action
    }

    var body: some View {
        Button(action: {
                    isHighlighted = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isHighlighted = false
                        action()
                    }
                }) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        List {
                            
                        }
                        

                        HStack {
                            
                            content
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                            //                            .foregroundColor(isHighlighted ? .white : .secondary)
                                .animation(.none, value: isHighlighted)
                        }
                        .contentShape(Rectangle())
                    }

                }
                .padding()
                #if canImport(UIKit)
                .background(isHighlighted ? Color(.systemGray6) : Color.clear)
                #else
                .background(isHighlighted ? Color(NSColor.controlBackgroundColor) : Color.clear)
                #endif
                .animation(.spring(), value: isHighlighted)

                .listRowInsets(EdgeInsets())
                .buttonStyle(PlainButtonStyle())
        

    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ForEach(1..<10) { item in

                RowView {
                    Text("Hello")
                } action: {
                    
                }

            }
            Divider()

            
        }
        
    }
}
