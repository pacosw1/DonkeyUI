//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 4/16/23.
//

import SwiftUI

public struct AppIdView: View {
    public init(id: String) {
        self.id = id
    }
    
    let id: String
    public var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Text("App ID:")
                .font(.caption2)
                .foregroundColor(.gray)
            Text(id == "" ? "Log in to iCloud" : id)
                .foregroundColor(.gray)
                .font(.caption)
                .textSelection(.enabled)
        }
    }
}

struct AppIdView_Previews: PreviewProvider {
    static var previews: some View {
        AppIdView(id: "some id")
    }
}
