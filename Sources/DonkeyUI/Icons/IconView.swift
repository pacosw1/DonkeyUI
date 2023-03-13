//
//  IconView.swift
//  Divergent
//
//  Created by Paco Sainz on 1/1/23.
//

import SwiftUI

public enum IconSize: CGFloat {
    case tiny = 25,
         micro = 10,
         verySmall = 30,
         small = 35,
         medium = 40,
        large = 45,
        veryLarge = 50,
        huge = 70
}

public struct IconView: View {
    let image: String
    let color: Color
    var size: IconSize = .large
    
    
    public init(image: String, color: Color, size: IconSize = .large) {
        self.image = image
        self.color = color
        self.size = size
        
    }
    var fontSize: CGFloat {
        switch size {
        case .micro:
            return 5
        case .tiny:
            return 10
        case .verySmall:
            return 12
        case .small:
            return 15
        case .medium:
            return 20
        case .large:
            return 23
        case .veryLarge:
            return 30
        case .huge:
            return 50
                }
    }
    
    public var body: some View {
        Image(systemName: image)
            .foregroundColor(.white)
            .font(.system(size: fontSize))
            .frame(width: size.rawValue, height: size.rawValue)
            .bgOverlay(bgColor: color.opacity(0.8), radius: 12)
    }
}

struct IconView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            IconView(image: "xmark", color: .pink, size: .micro)
            IconView(image: "xmark", color: .pink, size: .verySmall)
            IconView(image: "xmark", color: .pink, size: .small)
            IconView(image: "xmark", color: .pink, size: .medium)
            IconView(image: "xmark", color: .pink, size: .large)
            IconView(image: "xmark", color: .pink, size: .veryLarge)



        }
    }
}


