//
//  BackgroundModifier.swift
//  BuildUp
//
//  Created by Paco Sainz on 8/22/22.
//

import SwiftUI
import CoreHaptics

import SwiftUI

public struct PullList<Content: View>: View {
    
    var onPullThreshold: () -> Void = {}
    let content: Content
    
    init(@ViewBuilder content: () -> Content, onPull: @escaping () -> Void = {}) {
          self.content = content()
        self.onPullThreshold = onPull
      }
    
    @State private var storedOffsetY: CGFloat = 0.0 // New state variable

    @State private var isPerformingAction = false
    @State private var offsetY: CGFloat = 0.0
    @State private var showSearchBar = false
    @State private var searchText = ""
    private let actionThreshold: CGFloat = -80
    @State private var hasTriggeredHaptic = false
    
    private func performCustomAction(completion: @escaping () -> Void) {
        // Replace with your custom action
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            completion()
        }
    }
    
    public var searchIcon: some View {
        let circleProgress = min(1.0, max(0.0, (offsetY / actionThreshold) * 1))
        let handleProgress = min(1.0, max(0.0, (offsetY / actionThreshold) - 0.2))
//        let backgroundProgress = min(1.0, max(0.0, (offsetY / actionThreshold) - 0.4))

//        _ = max(0.0, handleProgress - 0.8) * 5
        let backgroundColor: Color = offsetY <= actionThreshold ? .blue : .gray


        return ZStack {
            // Background circle
            Circle()
                .fill(backgroundColor)
                .frame(width: 50, height: 50)
                .offset(x: 2, y: 2)
                .padding(12)
                .opacity(offsetY <= 0 ? 1 : 0) // Modified opacity based on offsetY

//                .opacity(circleProgress) // Added opacity modifier

            // Circle
            Circle()
                .trim(from: 0, to: circleProgress)
                .stroke(Color.white, lineWidth: 4)
                .frame(width: 20, height: 20)
                .rotationEffect(.degrees(-90))
            

            // Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white)
                .frame(width: 4, height: 3 + 6 * handleProgress)
                .offset(x: -1, y: -11.5 + -3.5 * handleProgress)
                .rotationEffect(.degrees(120.0 + 15.0 * handleProgress))
                .opacity(handleProgress)

//                                .opacity(offsetY < -60 ? Double((offsetY + 60) / -40) : 0)
            // Arrow
            
        }
        .position(x: UIScreen.main.bounds.width / 2, y: offsetY <= 0 ? max(offsetY * -1, 0) : 0)
        .opacity(offsetY <= 0 ? 1 : 0) // Modified opacity based on offsetY

        // Adjusted the position calculation
    }
    
    public var body: some View {
        GeometryReader { root in
            ZStack(alignment: .top) {
                List {
                    content
                    
                   .background(GeometryReader { proxy -> Color in
                        DispatchQueue.main.async {
                            offsetY = -proxy.frame(in: .named("scroll")).origin.y + root.safeAreaInsets.top
                            
                            if offsetY <= actionThreshold {
                                onPullThreshold()
                            }
                        }
                        return Color.clear
                        
                        
                    })
                    .listRowSeparator(.hidden)
                }
                .coordinateSpace(name: "scroll")
                .listStyle(.plain)
                
                searchIcon
                    .frame(maxWidth: .infinity, alignment: .top)
                    .opacity((offsetY) / actionThreshold)
//                    .offset(y: -proxy.safeAreaInsets.top)
                    .padding(0)
                    .ignoresSafeArea()
//                Text("offset: \(offsetY)" )
//                    .padding(0)

            }
            .padding(0)
        }
        .padding(0)
            
        }
}


//extension View {
//    public func pullList(onPull: @escaping () -> Void = {}) -> some View {
//        modifier(PullListModifier(onPullThreshold: onPull))
//
//    }
//}



struct PullList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PullList {
                Text("Hllo")
                    .font(.title)
                ForEach(1..<4) { item in
                    NavigationLink(destination: Text("hii")) {
                        Text("Hello")
                    }
                    
                }
            }
        }
        
//        .searchMod()
//        .preferredColorScheme(.dark)
    }
}


//public enum HapticFeedback {
//    static private var generator = UINotificationFeedbackGenerator()
//
//    static func trigger() {
//        generator.notificationOccurred(.success)
//    }
//}




//struct ViewOffsetKey: PreferenceKey {
//    typealias Value = CGFloat
//
//    static var defaultValue: CGFloat = 0.0
//
//    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//        value = nextValue()
//    }
//}
//
