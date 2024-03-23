//
//  SitesMap.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 2/17/24.
//

import SwiftUI
import MapKit

struct SitesMap: View {
    @State private var buildings: [Building] = []
    
    var body: some View {
        ZStack {
            MapView(buildings: buildings)
                .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                Spacer()
                Button(action: {
                    fetchBuildingsFromFirestore()
                }) {
                    Text("Refresh Buildings")
                }
                .padding()
            }
        }
    }
    
    private func fetchBuildingsFromFirestore() {
        Task {
            do {
                let fetchedBuildings = try await BuildingsManager.shared.getAllBuildings(descending: nil, group: nil)
                DispatchQueue.main.async {
                    self.buildings = fetchedBuildings
                }
            } catch {
                print("Error fetching buildings: \(error)")
            }
        }
    }
}



struct MapView: UIViewRepresentable {
    @State private var userTrackingMode: MKUserTrackingMode = .follow
    private let locationManager = CLLocationManager()
    
    let buildings: [Building]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.userTrackingMode = userTrackingMode
        
        locationManager.delegate = context.coordinator
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        
        mapView.showsUserLocation = true
        locationManager.requestWhenInUseAuthorization()
        
        addAnnotations(to: mapView)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.userTrackingMode = userTrackingMode
        addAnnotations(to: uiView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func addAnnotations(to mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        
        
        
        for building in buildings {
            if let coordinates = building.coordinates {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                switch building.siteGroup {
                                case "R1":
                                    annotation.subtitle = "R1"
                                case "G1":
                                    annotation.subtitle = "G1"
                                case "G2":
                                    annotation.subtitle = "G2"
                                case "G3":
                                    annotation.subtitle = "G3"
                                // Add more cases as needed
                                default:
                                    annotation.subtitle = "No site group"
                            }
                annotation.title =  building.name ?? ""
                mapView.addAnnotation(annotation)
            }
        }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SitesMap()
    }
}

