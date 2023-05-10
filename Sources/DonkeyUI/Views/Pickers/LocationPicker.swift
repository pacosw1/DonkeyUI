//
//  SwiftUIView.swift
//  
//
//  Created by Paco Sainz on 5/6/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct LocationPicker: View {
    
    @State var shown = false
    
    @State var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    let locations = [
        Location(name: "Buckingham Palace", coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
        Location(name: "Tower of London", coordinate: CLLocationCoordinate2D(latitude: 51.508, longitude: -0.076))
    ]
    

    var body: some View {
            
        VStack {
            Button("Hello", action: {
                shown.toggle()
            })
            
           
        }
        .floatingMenuSheet(isPresented: $shown) {
            HStack {
                IconView(image: "drop.fill", color: .blue)
                Text("Hello world")
                Spacer()
                
                
            }
//            .padding()
        }
        
        }
    
}

struct LocationPicker_Previews: PreviewProvider {
    static var previews: some View {
        LocationPicker()
    }
}
