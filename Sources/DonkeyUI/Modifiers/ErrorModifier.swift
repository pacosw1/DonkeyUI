//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 3/14/23.
//

import PopupView
import SwiftUI

public struct ErrorModifier: ViewModifier {
    var errorMessage: String = "Connection Error"
    var subText: String = "Please try again later"
    var errorType: ErrorType = .wifi
    @Binding var presented: Bool
  
    public func body(content: Content) -> some View {
        content
            .popup(isPresented: $presented) {
                HStack {
                    IconView(image: "wifi.exclamationmark", color: .clear)
                    VStack(alignment: .leading) {
                        Text(errorMessage)
                            .fontWeight(.heavy)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Text(subText)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .card(color: .pink.opacity(0.9))

            } customize: {
                $0
                    .type(.floater())
                    .position(.top)
                    .animation(.spring())
                    .closeOnTapOutside(true)
                    .autohideIn(3)
            }
    }
}

public extension View {
    func errorToast(errorMessage: String = "Connection Error", presented: Binding<Bool>) -> some View {
        modifier(ErrorModifier(errorMessage: errorMessage, presented: presented))
    }
}
