//
//  BadgeLabelView.swift
//  Divergent
//
//  Created by paco on 29/11/22.
//

import SwiftUI

struct BadgeLabelView: View {
    let count: Int
    var color = Color.pink
    var body: some View {
        Text("\(count)")
            .foregroundColor(color == .clear ? .gray : .white)
        .fontWeight(.semibold)
        .font(.callout)
        .monospacedDigit()
        .padding(.vertical, 3)
        .padding(.horizontal, 10)
        .bgOverlay(bgColor: color, radius: 50)
    }
}

struct BadgeLabelView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeLabelView(count: 100)
    }
}
