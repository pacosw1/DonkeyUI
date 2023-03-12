//
//  File.swift
//  
//
//  Created by Paco Sainz on 3/12/23.
//

import SwiftUI

struct IdentifiableView: Identifiable {
    var id = UUID()
    var view: AnyView
    var maxWidth: CGFloat = 300
}

struct PaywallFeatureSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var lastUpdate: Int64 = 0
    @State var selection: Int = 0
    
    let views: [IdentifiableView]
    
    var body: some View {
        TabView(selection: $selection) {
            
            ForEach(views.indices, id: \.self) { i in
                views[i].view
                    .frame(maxWidth: views[i].maxWidth)
                    .tag(i)
            }
        }
        .onAppear() {
            if colorScheme == .light {
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.primary)
                UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.secondary.opacity(0.4))
            } else {
                UIPageControl.appearance().currentPageIndicatorTintColor = .white
                UIPageControl.appearance().pageIndicatorTintColor = .darkGray
            }
            
            lastUpdate = Date.now.timestamp()
        }
        
        .tabViewStyle(.page(indexDisplayMode: .always))

    }
}
