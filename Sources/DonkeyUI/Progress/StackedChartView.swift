//
//  ChartView.swift
//  Gools
//
//  Created by Paco Sainz on 4/5/23.
//

import SwiftUI

public struct BarItem: Identifiable {
    public init(color: Color, amount: Double, name: String) {
        self.color = color
        self.amount = amount
        self.name = name
    }
    
    public let id = UUID()
    public let color: Color
    public let amount: Double
    public let name: String
}

public struct StackedChartView: View {
    public init(barItems: [BarItem], height: CGFloat = 25) {
        self.barItems = barItems
        self.height = height
    }
    
    var barItems: [BarItem]
    var height: CGFloat

    private var total: Double {
            barItems.reduce(0) { $0 + $1.amount }
    }

    private func percentage(for amount: Double) -> Double {
        (amount / total) * 100
    }

    public var body: some View {
        VStack {
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
            .frame(height: height)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 15) {
                    ForEach(barItems) { item in
                        HStack(spacing: 5) {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(item.color)
                            Text(item.name)
                                .font(.caption)
                            Text((percentage(for: item.amount)).percentageLabel)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.bottom)
            }
        }
    }
}

struct StackedChartView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StackedChartView(barItems: [.init(color: .blue, amount: 300, name: "Social"), .init(color: .pink, amount: 140, name: "Internet"), .init(color: .orange, amount: 90, name: "Sports")])
            Spacer()
         
        }
        .padding()
    }
}
