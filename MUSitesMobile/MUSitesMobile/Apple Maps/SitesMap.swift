//
//  SitesMap.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 2/17/24.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let universityLocation = CLLocationCoordinate2D(latitude: 38.9407, longitude: -92.3279)
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        let region = MKCoordinateRegion(center: universityLocation, latitudinalMeters: 500, longitudinalMeters: 1000) //Adjust zoom level
        mapView.setRegion(region, animated: true)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        //We can customize the map view here if needed
    }
}

struct SitesMap: View {
    var body: some View {
        VStack {
            Spacer().frame(height: 50) //spacer with a fixed height at the top
            
            MapView() //Implement Apple Maps
                .frame(height: 700) // Set a fixed height for the map
                .edgesIgnoringSafeArea(.all)
            
            Text("Sites Map")
                .font(.title)
                .fontWeight(.bold)
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SitesMap()
    }
}

