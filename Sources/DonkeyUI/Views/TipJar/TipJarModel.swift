//
//  File.swift
//  
//
//  Created by Paco Sainz on 3/11/23.
//

import Foundation


//protocol TipJarOption: Identifiable {
//    func getPrice() -> CGFloat
//    func getLabel() -> String
//    func getId() -> UUID
//    var id: UUID { get }
////    func getCurrency(): String
//}


struct TipJarOption: Identifiable {
    let id = UUID()
    let label: String
    let price: Float
}

class TipJarModel: ObservableObject {
    
}
