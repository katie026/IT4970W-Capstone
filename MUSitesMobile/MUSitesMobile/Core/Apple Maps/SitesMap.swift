//
//  SitesMap.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 2/17/24.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @State private var userTrackingMode: MKUserTrackingMode = .follow
    private let locationManager = CLLocationManager()
    let universityLocation = CLLocationCoordinate2D(latitude: 38.9407, longitude: -92.3279)
    let locations: [(CLLocationCoordinate2D, String, String)] = [
        (CLLocationCoordinate2D(latitude: 38.9407, longitude: -92.3279), "Mizzou", "University of Missouri"),
        (CLLocationCoordinate2D(latitude: 38.944356912417696, longitude: -92.32648961697893), "Ellis Library", "University of Missouri")
    ]
    
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
    }
}

struct SitesMap: View {
    @State private var showLegend = false
    
    var body: some View {
        ZStack {
            MapView()
                .edgesIgnoringSafeArea(.all)
            
            if showLegend {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 20) {
                            LegendItem(color: .red, label: "G1")
                            LegendItem(color: .blue, label: "G2")
                            LegendItem(color: .green, label: "G3")
                            LegendItem(color: .orange, label: "R1")
                            LegendItem(color: .purple, label: "R2")
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                    }
                }
                .padding(.bottom, 50)
                .padding(.trailing, 20)
            }
            
            VStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        showLegend.toggle()
                    }
                }) {
                    Text(showLegend ? "Hide Legend" : "Show Legend")
                }
                .padding()
            }
        }
    }
}



struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 20, height: 20)
                .padding(.trailing, 5)
            Text(label)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SitesMap()
    }
}
