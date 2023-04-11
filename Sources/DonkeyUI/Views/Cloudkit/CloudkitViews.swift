//
//  SwiftUIView 2.swift
//  
//
//  Created by Paco Sainz on 4/11/23.
//

import SwiftUI

struct CloudKitStatusRow: View {
    let label: String
    let okay: Bool
    var secondaryLabel: String
    
    var color: Color {
        let color: Color = okay ? .green : .pink
        return color.opacity(0.8)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            
            VStack(alignment: .leading) {
                Text(label)
                    .fontWeight(.semibold)
                    .font(.body)
               
                Text(secondaryLabel)
                    .font(.callout)
                    .foregroundColor(okay ? .gray : .pink.opacity(0.8))
                    .fontWeight(okay ? .regular : .semibold)
                
            }
            Spacer()
            Image(systemName: okay ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(color)
                .font(.system(size: 20))
//                .padding(1)
//                .bgOverlay(bgColor: .gray.opacity(<#T##opacity: Double##Double#>), radius: 100)
        }
        .frame(height: 40)
    }
}

struct CloudKitStatusRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            CloudKitStatusRow(label: "iCloud account", okay: true, secondaryLabel: "Logged in")
            CloudKitStatusRow(label: "iCloud account", okay: false, secondaryLabel: "Not Logged in")
        }
//        .padding()
    }
}
