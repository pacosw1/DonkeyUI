//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 3/11/23.
//

import SwiftUI

struct CloseButton: View {
    var size: ButtonSize = .medium
    var action: () -> Void

    var getSizeInFont: Font {
        switch size {
        case .tiny:
            return .body
        case .verySmall:
            return .headline
        case .small:
            return .title3
        case .medium:
            return .title2
        case .large:
            return .title
        }
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray.opacity(0.5))
                .font(getSizeInFont)
        }
    }
}

struct CloseButton_Previews: PreviewProvider {
    static var previews: some View {
        CloseButton(size: .medium, action: {})
    }
}
