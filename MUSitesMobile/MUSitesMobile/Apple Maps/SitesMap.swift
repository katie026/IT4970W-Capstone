//
//  SitesMap.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 2/17/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    @State private var userTrackingMode: MKUserTrackingMode = .follow
    // LocationManager to handle location authorization
    private let locationManager = CLLocationManager()
    // Mizzou coordinates
    let universityLocation = CLLocationCoordinate2D(latitude: 38.9407, longitude: -92.3279)
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.userTrackingMode = userTrackingMode // Set initial user tracking mode
        
        // Set initial region
        let region = MKCoordinateRegion(center: universityLocation, latitudinalMeters: 500, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        locationManager.delegate = context.coordinator // Set delegate for location updates
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Get best accuracy possible
        locationManager.distanceFilter = 10 // Set distance filter for updates
        
        // Show user's location on map
        mapView.showsUserLocation = true
        
        // Request location authorization
         
        locationManager.requestWhenInUseAuthorization()
        
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update user tracking mode when it changes
        uiView.userTrackingMode = userTrackingMode
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, CLLocationManagerDelegate {
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            // Check authorization status
            if status == .authorizedWhenInUse {
                manager.startUpdatingLocation()
            }
        }
    }
}

struct SitesMap: View {
    var body: some View {
        NavigationView {
            MapView()
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SitesMap()
    }
}

