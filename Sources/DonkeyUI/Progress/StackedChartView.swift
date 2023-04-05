//
//  ChartView.swift
//  Gools
//
//  Created by Paco Sainz on 4/5/23.
//

import SwiftUI

public struct BarItem: Identifiable {
    public let id = UUID()
    let color: Color
    let amount: Double
}

public struct StackedChartView: View {
    public init(barItems: [BarItem]) {
        self.barItems = barItems
    }
    
    var barItems: [BarItem]

    private var total: Double {
            barItems.reduce(0) { $0 + $1.amount }
    }

    private func percentage(for amount: Double) -> Double {
        (amount / total) * 100
    }

    public var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                ForEach(barItems) { item in
                    Rectangle()
                        .fill(item.color)
                        .frame(width: geometry.size.width * CGFloat(percentage(for: item.amount)) / 100)
                }
            }
            .animation(.interactiveSpring(), value: total)
        }
        .frame(height: 25)
    }
}

struct StackedChartView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StackedChartView(barItems: [.init(color: .blue, amount: 10), .init(color: .pink, amount: 10), .init(color: .orange, amount: 10)])
            Spacer()
            Button("hi") {
                
            }
        }
    }
}
