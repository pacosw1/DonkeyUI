//
//  CalendarItemView.swift
//  BuildUp
//
//  Created by paco on 02/09/22.
//

import SwiftUI

public struct CalendarIconView: View {
    
    var date: Date
    var dots: Bool = false
    var dateNumber: String {
        if dots {
            return "..."
        }
        return "\(date.day)"
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(.red)
                .frame(width: 27, height: 8, alignment: .center)
                .cornerRadius(5, corners: [.topLeft, .topRight])
            
            Rectangle()
                .fill(.tertiary)
                .frame(width: 27, height: 18, alignment: .center)

                .cornerRadius(5, corners: [.bottomLeft, .bottomRight])
                .overlay {
                        VStack(alignment: .trailing) {
                            Text(dateNumber)
                                .font(.system(size: 12))
                                .fontWeight(.bold)
                                .offset(y: -1.5)
                        }
                }   
        }
    }
}

struct CalendarItemView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarIconView(date: Date.now)
    }
}
