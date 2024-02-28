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
    private let locationManager = CLLocationManager()
    let universityLocation = CLLocationCoordinate2D(latitude: 38.9407, longitude: -92.3279)
    let locations: [(CLLocationCoordinate2D, String, String)] = [
        (CLLocationCoordinate2D(latitude: 38.9407, longitude: -92.3279), "Mizzou", "University of Missouri"),
        (CLLocationCoordinate2D(latitude: 38.944356912417696, longitude: -92.32648961697893), "Ellis Library", "University of Missouri")
    ]
    
    // Adjusted coordinates for the circle overlay
    let ellisLibraryOverlayCenter = CLLocationCoordinate2D(latitude: 38.944356912417696, longitude: -92.32648961697893)
    let ellisLibraryOverlayRadius: CLLocationDistance = 50
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator // Set delegate for map view
        
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
        
        // Add annotations for each location
        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.0
            annotation.title = location.1
            annotation.subtitle = location.2
            mapView.addAnnotation(annotation)
        }
        
        // Add overlay for Ellis Library
        let ellisLibraryOverlay = MKCircle(center: ellisLibraryOverlayCenter, radius: ellisLibraryOverlayRadius)
        mapView.addOverlay(ellisLibraryOverlay)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.userTrackingMode = userTrackingMode
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CLLocationManagerDelegate, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse {
                manager.startUpdatingLocation()
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circleOverlay)
                renderer.fillColor = UIColor.yellow.withAlphaComponent(0.5)
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

struct SitesMap: View {
    @State private var showLegend = true
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                // Button to toggle legend visibility
                Button(action: {
                    withAnimation {
                        self.showLegend.toggle()
                    }
                }) {
                    Text(showLegend ? "Hide Legend" : "Show Legend")
                }
                .padding()
            }
            MapView()
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    // Legends for map overlays
                    VStack {
                        if showLegend {
                            HStack {
                                Circle()
                                    .fill(Color.red.opacity(0.5))
                                    .frame(width: 20, height: 20)
                                Text("G1")
                                    .padding(.leading, 5) // Adjust padding for better alignment
                            }
                            HStack {
                                Circle()
                                    .fill(Color.yellow.opacity(0.5))
                                    .frame(width: 20, height: 20)
                                Text("G2")
                                    .padding(.leading, 5)                            }
                            HStack {
                                Circle()
                                    .fill(Color.green.opacity(0.5))
                                    .frame(width: 20, height: 20)
                                Text("G3")
                                    .padding(.leading, 5)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    , alignment: .bottomTrailing // Align the legend
                )
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SitesMap()
    }
}

