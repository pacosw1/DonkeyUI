//
//  SwiftUIView.swift
//
//
//  Created by Paco Sainz on 3/14/23.
//

import SwiftUI
#if canImport(PopupView)
import PopupView
#endif

public struct ErrorModifier: ViewModifier {
    var errorMessage: String = "Connection Error"
    var subText: String = "Please try again later"
    var errorType: ErrorType = .wifi
    @Binding var presented: Bool

    public func body(content: Content) -> some View {
        #if canImport(PopupView)
        content
            .popup(isPresented: $presented) {
                HStack {
                    IconView(image: "wifi.exclamationmark", color: .clear)
                    VStack(alignment: .leading) {
                        Text(errorMessage)
                            .fontWeight(.heavy)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Text(subText)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
                .card(color: .pink.opacity(0.9))

            } customize: {
                $0
                    .type(.floater())
                    .position(.top)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8))
                    .closeOnTapOutside(false)
                    .autohideIn(3)
            }
        #else
        content
        #endif
    }
}

public extension View {
    func errorToast(errorMessage: String = "Connection Error", presented: Binding<Bool>) -> some View {
        modifier(ErrorModifier(errorMessage: errorMessage, presented: presented))
    }
}
