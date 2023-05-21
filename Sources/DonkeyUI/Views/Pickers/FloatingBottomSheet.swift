//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 5/6/23.
//

import SwiftUI


public enum CardPosition: Int {
    case bottom = 0,
    center,
    top
    
}

public struct FloatingBottomSheet<CustomView>: ViewModifier where CustomView: View {
    @Binding var isShown: Bool
    let padding: CGFloat = 50
    let sheetContent: () -> CustomView
    let position: CardPosition
    var paddingBottom = 0.0
    
    
    @State var contentHeight: CGFloat = 0.0
    @State var proxyHeight: CGFloat = 0.0
    @GestureState private var translation: CGSize = CGSize()

    
    
    func fadeProgress(current: CGFloat, total: CGFloat) -> CGFloat {
        var multiplier = 1.0
        let maxOpacity = 0.3
        
        if !isShown {
            return 0
        }
        
        if position == .center {
            return 0.3
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
    
    
    
    
    func shownPosition(height: CGFloat, cardHeight: CGFloat) -> CGFloat {
        let padding = 15.0
        
        
        if position == .bottom {
            return height - cardHeight - padding
        } else if position == .center {
            return (height / 2) - (cardHeight / 2) - padding

        }
//
        
        return height
        
    }
    
    func hiddenPosition(height: CGFloat, cardHeight: CGFloat) -> CGFloat {
        let padding = 15.0
        
        
        if position == .bottom {
            return height
        } else if position == .center {
            return height
        }
        
//
//
        
        return height
        
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
                        VStack(alignment: .leading) {
                            sheetContent()
                        }
                            .card(color: .white, radius: .bottomMenu)
                            .height(height: $contentHeight)
                            .offset(y: position == .center ? 0 : self.translation.height)
                            .offset(y: isShown ? shownPosition(height: proxyHeight, cardHeight: contentHeight): hiddenPosition(height: proxyHeight, cardHeight: contentHeight))
//                            .opacity(isShown ? 1 : 0.8)
                            .padding(.bottom, paddingBottom)
                        
                          

                            .simultaneousGesture(
                                DragGesture(minimumDistance: 10).updating(self.$translation) { value, state, nigger in
                                    
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
                .height(height: $proxyHeight)
                .animation(.interpolatingSpring(stiffness: 300, damping: 100), value: isShown)
                .animation(.interactiveSpring(), value: self.translation.height)
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
        .floatingMenuSheet(isPresented: .constant(false), content:  {
            Text("Hello")
        }, position: .center)
    }
}

extension View {
    public func floatingMenuSheet<CustomView>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> CustomView, position: CardPosition = .center, paddingBottom: CGFloat = 0) -> some View where CustomView: View {
        modifier(FloatingBottomSheet(isShown: isPresented, sheetContent: content, position: position, paddingBottom: paddingBottom))
    }
}
