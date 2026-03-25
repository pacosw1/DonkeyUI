//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 3/14/23.
//
import SwiftUI


enum ErrorType {
case wifi,
     validation,
     cloud
     
}

struct ErrorView: View {
    var errorMessage: String = "Connection Error"
    var subText: String = "Please try again later"
    var errorType: ErrorType = .wifi
    @State private var presented = false
    var body: some View {
        VStack {
            Text("Hello")
                .errorToast(presented: $presented)
        }
        .onTapGesture {
            presented.toggle()
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
