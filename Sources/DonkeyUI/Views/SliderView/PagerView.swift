//
//  PagerView.swift
//  BuildUp
//
//  Created by paco on 28/09/22.
//

import SwiftUI

public struct SwipableView: Identifiable {
    public var id = UUID()
    var view: AnyView
}

public struct PagerView: View {
    var swipeAction: (Bool) -> Void
    @Binding var page: Int
    var views: [SwipableView] = []
    @State var dragging: Bool = false
    
    public init(swipeAction: @escaping (Bool) -> Void, page: Binding<Int>, views: [SwipableView] = []) {
        self.swipeAction = swipeAction
        _page = page
        self.views = views
        self.dragging = false
    }
    
    @GestureState private var translation: CGSize = CGSize()
    
   
    @Environment(\.managedObjectContext) private var moc
    
    public var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                        ForEach(views) { view in
                            view.view
                                .frame(width: geometry.size.width)
                        }
                }
                .offset(x: -CGFloat(page) * geometry.size.width)
                .offset(x: self.translation.width)
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0.8).updating(self.$translation) { value, state, nigger in
                        state = value.translation

                    }.onChanged { value in
                            withAnimation(.none) {
//                                hideSelector = true
                            }
                    }
                    .onEnded { value in
                        let hOffset = value.translation.width / geometry.size.width
                        let hDir = hOffset < 0 ? 1 : 0
                        
                        if abs(hOffset) < 0.35 {
//                            hideSelector = false
                            return
                        }
  
                        if hDir == 0 {
//                            if page > 0 {
                                page -= 1
//                            }
//                            sel.swipeAction()
                            self.swipeAction(false)

                        } else {
//                            if page < self.views.count - 1 {
                                page += 1
//                            }
                            self.swipeAction(true)
                        }
                        
                        withAnimation(.interactiveSpring().delay(0.2)) {
//                            hideSelector = false
                        }
                    }
                    
                )
                .animation(.interpolatingSpring(stiffness: 300, damping: 2000), value: translation.width)
                .frame(width: geometry.size.width,  alignment: .leading)
            }
        }
        .frame(maxHeight: .infinity)
        
//        .task {
//            model.updateDayCounts(context: moc)
//        }
        
    }
}

struct PagerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PagerView(swipeAction: {dir in}, page: .constant(1), views: [
                .init(view: AnyView(Color.red)),
                .init(view: AnyView(Color.blue)),
                .init(view: AnyView(Color.orange))])
        }
    }
}
