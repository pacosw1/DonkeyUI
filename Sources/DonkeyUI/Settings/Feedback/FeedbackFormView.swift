//
//  FeedbackView.swift
//  Divergent
//
//  Created by paco on 13/12/22.
//

import SwiftUI

struct FeedbackFormView: View {
    
    @State var text = ""
    @State var email = ""
    @Binding var state: FeedbackState
    @FocusState var focused: Bool
    
    var onSubmit: (String, String) -> Void = {_, _ in}

    var progress: CGFloat {
        return 0.999 - CGFloat(Float(text.count) / 250.0)
    }
        
    var disabled: Bool {
        return text.count < 10 || text.count > 250
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
//            HStack(alignment: .center) {
               
//            }
//            .padding(.leading ,8)
//            .padding(.bottom, -5)
            ZStack(alignment: .bottomLeading) {
                CircularProgressView(color: disabled ? .pink : .accentColor, progress: progress, size: 8)
                    .animation(.easeIn, value: disabled)
                    .padding()
//
                VStack(alignment: .leading) {
                    TextField("Let us know if you have a cool idea, feature suggestion, or anything else", text: $text, axis: .vertical)
                        .padding()
                        .multilineTextAlignment(.leading)
                        .lineLimit(8)
                        .focused($focused)
                    Spacer()
                }
            }
            .frame(minHeight: 200)
            .frame(maxHeight: 200)
            .bordered()
                
            
            TextField("Email (optional, if you want a response)", text: $email)
                .padding()
                .bordered()
           
           
            Spacer()
        }
        .padding()
        .navigationTitle("Feedback")
        .task {
//            focused = true
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ButtonView(label: "Send",  padding: 1, fullWidth: true) {
                    onSubmit(text, email)
                    
                    focused = false
                    
                    withAnimation {
                        state = .sent
                    }
                    
                }
                .disabled(disabled)
            }
        }
    }
}

struct FeedbackFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FeedbackFormView(state: .constant(.form))
        }
    }
}
