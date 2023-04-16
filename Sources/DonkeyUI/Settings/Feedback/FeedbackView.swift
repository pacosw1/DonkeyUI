//
//  FeedbackContainerView.swift
//  Divergent
//
//  Created by paco on 13/12/22.
//

import SwiftUI

enum FeedbackState: Int {
    case form = 0,
    sent
}

public struct FeedbackView: View {
    public init(onSubmit: @escaping (String, String) -> Void) {
        self.state = .form
        self.onSubmit = onSubmit
    }
    
    @State var state: FeedbackState
    var onSubmit: (String, String) -> Void
    
    public var body: some View {
        switch state {
        case .form:
            FeedbackFormView(state: $state)
        case .sent:
            FeedbackSentView(action: {
                withAnimation {
                    state = .form
                }
            })
            .onDisappear {
                state = .form
            }
        }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView(onSubmit: {_, _ in})
    }
}
