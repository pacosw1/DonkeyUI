//
//  SwiftUIView.swift
//
//
//  Created by Paco Sainz on 4/16/23.
//

import SwiftUI

public struct LeaveReviewView: View {
    public init(url: String) {
        self.showError = false
        self.url = url
    }

    @State var showError = false
    let url: String
    public var body: some View {
        IconRowView(icon: "star.fill", label: "Leave a Review", color: .yellow, badgeCount: 0)
            .errorToast(errorMessage: "Could not open the review page", presented: $showError)
            .contentShape(Rectangle())
            .onTapGesture {
                guard let writeReviewURL = URL(string: url)
                    else {
                    showError = true
                    return
                }
                #if canImport(UIKit)
                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                #else
                NSWorkspace.shared.open(writeReviewURL)
                #endif
            }

    }
}

struct LeaveReviewView_Previews: PreviewProvider {
    static var previews: some View {
        LeaveReviewView(url: "nice cock")
    }
}

//https://apps.apple.com/app/id6443977467?action=write-review
