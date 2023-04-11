//
//  SwiftUIView 2.swift
//  
//
//  Created by Paco Sainz on 4/11/23.
//

import SwiftUI

struct CloudkitHeader: View {
    let okay: Bool
    var body: some View {
        HStack {
            Text("")
        }
    }
}

struct CloudkitHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CloudkitHeader(okay: false)
            CloudkitHeader(okay: true)

        }
    }
}
