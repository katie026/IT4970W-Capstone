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
    let locations: [(CLLocationCoordinate2D, String, String)] = [
            (CLLocationCoordinate2D(latitude: 38.9407, longitude: -92.3279), "Mizzou", "University of Missouri"),
            (CLLocationCoordinate2D(latitude: 38.944782, longitude: -92.3274335), "Ellis Library", "University of Missouri")
            // Add more locations as needed
        ]
    
    
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
        
        
        // Add annotations for each location in the array
                for location in locations {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location.0
                    annotation.title = location.1
                    annotation.subtitle = location.2
                    mapView.addAnnotation(annotation)
                }
                
                return mapView
        
        
        
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update user tracking mode when it changes
        uiView.userTrackingMode = userTrackingMode
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CLLocationManagerDelegate {
        
        var parent: MapView
                
                init(_ parent: MapView) {
                    self.parent = parent
                }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            // Check authorization status
            if status == .authorizedWhenInUse {
                manager.startUpdatingLocation()
            }
        }
        
        // Implement didSelect method
                func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
                    guard let annotation = view.annotation else {
                        return
                    }
                    // Show callout with title and subtitle
                    mapView.deselectAnnotation(annotation, animated: true)
                    mapView.selectAnnotation(annotation, animated: true)
                }
                
                // Implement viewFor method
                func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
                    guard !(annotation is MKUserLocation) else {
                        return nil
                    }
                    
                    let identifier = "annotationView"
                    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                    
                    if annotationView == nil {
                        annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                        annotationView?.canShowCallout = true
                    } else {
                        annotationView?.annotation = annotation
                    }
                    
                    return annotationView
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

