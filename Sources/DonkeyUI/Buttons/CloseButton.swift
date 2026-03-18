//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 3/11/23.
//

import SwiftUI

public struct CloseButton: View {
    var size: ButtonSize = .medium
    var action: () -> Void
    
    public init(size: ButtonSize = .medium, action: @escaping () -> Void) {
        self.size = size
        self.action = action
    }

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
    
    public var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray.opacity(0.5))
                .font(getSizeInFont)
        }
        .accessibilityLabel("Close")
    }
}

struct CloseButton_Previews: PreviewProvider {
    static var previews: some View {
        CloseButton(size: .medium, action: {})
    }
}
