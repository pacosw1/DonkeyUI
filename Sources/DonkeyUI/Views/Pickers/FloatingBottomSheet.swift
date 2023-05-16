//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 5/6/23.
//

import SwiftUI

public struct FloatingBottomSheet<CustomView>: ViewModifier where CustomView: View {
    @Binding var isShown: Bool
    let padding: CGFloat = 50
    let sheetContent: () -> CustomView
    
    
    @State var contentHeight: CGFloat = 0.0
    @State var proxyHeight: CGFloat = 0.0
    @GestureState private var translation: CGSize = CGSize()

    
    
    func fadeProgress(current: CGFloat, total: CGFloat) -> CGFloat {
        var multiplier = 1.0
        let maxOpacity = 0.3
        
        if !isShown {
            return 0
        }
        if self.translation.height == 0 {
            multiplier = 1
        } else {
            if translation.height < 0 {
                multiplier = 1
            } else {
                multiplier = 1 - (self.translation.height / (contentHeight))
            }
        }
        return multiplier * maxOpacity
    }
    
    
    @ViewBuilder
    public func body(content: Content) -> some View {
                ZStack {
                    content
                    Color.black
                        .opacity(fadeProgress(current: self.translation.height, total:  proxyHeight - contentHeight))
                        .ignoresSafeArea(.all)
                        .onTapGesture {
                                isShown = false
                        }
                        .animation(.linear, value: fadeProgress(current: self.translation.height, total:  proxyHeight - contentHeight))

                    GeometryReader { itemProxy in
                        sheetContent()
                            .card(color: .white, radius: .bottomMenu)
                            .height(height: $contentHeight)
                            .offset(y: self.translation.height)
                            .offset(y: isShown ? proxyHeight - contentHeight + 20 : proxyHeight + contentHeight * 2)
                            .animation(.spring(), value: isShown)
                            .animation(.interactiveSpring(), value: self.translation.height)

                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0).updating(self.$translation) { value, state, nigger in
                                    
                                    if value.translation.height >= -30 {
                                        state = value.translation

                                    }
                                    

                                }.onChanged { value in
                                
                                }
                                .onEnded { value in
                                    let vOffset = value.translation.height / contentHeight
             
                                    let dir = vOffset < 0 ? 1 : 0
                                    
//                                    if value.translation.height < -30 {
//                                        withAnimation(.interactiveSpring()) {
//                                            translation = CGSize()
//                                        }
//                                        return
//                                    }
                                    
                                    if abs(vOffset) < 0.05 {
                                        return
                                    }
              
                                    if dir == 0 {
                                        withAnimation(.spring()) {
                                            isShown = false
                                        }
                                    } else {
                                        isShown = true
                                    }
                                    
                                    withAnimation(.interactiveSpring().delay(0.2)) {
                                    }
                                    
                                
                                }
                                
                            )
                            
                    }
                    .onChange(of: isShown) { _ in
                        if !isShown {
//                            position = CGSize()
                        }
                    }
                    .padding()
                    
                }
                .ignoresSafeArea(.all)
                .height(height: $proxyHeight)
                
            
            // MArk
//            .padding()
    }
}

extension Binding {
  static func mock(_ value: Value) -> Self {
    var value = value
    return Binding(get: { value },
                   set: { value = $0 })
  }
}

struct ButtomSheetCard_Previews: PreviewProvider {
    
    
    
    static var previews: some View {
        
        VStack {
            Text("Hi")
         
            
            HStack {
                Text("Nice job")
                Spacer()
                Text("mot ice")
            }
        }
        
        .padding()
        .padding(.bottom)
        .floatingMenuSheet(isPresented: .constant(false)) {
            Text("Hello")
        }
    }
}

extension View {
    public func floatingMenuSheet<CustomView>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> CustomView) -> some View where CustomView: View {
        modifier(FloatingBottomSheet(isShown: isPresented, sheetContent: content))
    }
}
