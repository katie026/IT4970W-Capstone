//
//  SimpleMapView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/14/24.
//

import SwiftUI
import MapKit

struct SimpleMapView: View {
    private var centerCoordinate: CLLocationCoordinate2D
    private var label: String
    private let zoomLevel: Double = 300
    
//    @State private var region = MKCoordinateRegion( // Initial region
//      center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
//      span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//    )
    
    init(coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), label: String = "N/A") {
        self.centerCoordinate = coordinates
        self.label = label
    }
    
    var body: some View {
        Map () {
            Marker(coordinate: centerCoordinate) { // marker at coordinate
                Text(label)
            }
            
        }
        .edgesIgnoringSafeArea(.all) // Ignore safe area for full screen map
    }
    
    private var region: MKCoordinateRegion {
        let span = MKCoordinateSpan(latitudeDelta: zoomLevel, longitudeDelta: zoomLevel)
        return MKCoordinateRegion(center: centerCoordinate, span: span)
    }
}

#Preview {
    SimpleMapView(coordinates: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), label: "Middlebush")
}
