//
//  File.swift
//  
//
//  Created by Paco Sainz on 3/12/23.
//

import SwiftUI

struct PaywallHeaderView: View {
    var closeAction: () -> Void
    var isSheet: Bool
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center) {
                HStack(alignment: .center, spacing: 5) {
                    Text("Divergent")
                        .font(.title3)
                        .fontWeight(.heavy)

                    Text("Pro")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .bgOverlay(bgColor: .accentColor, radius: 12)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .padding(.top, 5)
            }
            Spacer()
            if !isSheet {
                Button {
                    closeAction()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.title2)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, isSheet ? 10 : 0)
        .padding(.bottom, 10)
    }
}
