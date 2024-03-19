//
//  SitesMapView.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 2/17/24.
//

import SwiftUI
import MapKit

struct SitesMapView: View {
    @State private var selectedBuilding: Building? = nil
    
    
    var body: some View {
            NavigationView {
                ZStack {
                    MapView(selectedBuilding: $selectedBuilding)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            // Refresh button action
                            // fetchBuildingsFromFirestore()
                        }) {
                            Text("Refresh Buildings")
                        }
                        .padding()
                    }
                }
                .navigationTitle("Map")
                .navigationBarHidden(true)
                .background(
                    NavigationLink(
                        destination: selectedBuilding != nil ? BuildingCellView(building: selectedBuilding!) : nil,
                        isActive: Binding<Bool>(
                            get: { selectedBuilding != nil },
                            set: { newValue in
                                if !newValue { // NavigationLink became inactive
                                    selectedBuilding = nil // Reset selectedBuilding
                                }
                            }
                        )
                    ) {
                        EmptyView()
                    }
                    .hidden()
                )
            }
        }
    }
   



struct MapView: UIViewRepresentable {
    @State private var userTrackingMode: MKUserTrackingMode = .follow
    @Binding var selectedBuilding: Building?
    private let locationManager = CLLocationManager()
    
    @State private var buildings: [Building] = []
    
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
        
        fetchBuildingsFromFirestore { fetchedBuildings in
                    self.buildings = fetchedBuildings
                    addAnnotations(to: mapView)
                }
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.userTrackingMode = userTrackingMode
        addAnnotations(to: uiView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func fetchBuildingsFromFirestore(completion: @escaping ([Building]) -> Void) {
            Task {
                do {
                    let fetchedBuildings = try await BuildingsManager.shared.getAllBuildings(descending: nil, group: nil)
                    DispatchQueue.main.async {
                        completion(fetchedBuildings)
                    }
                } catch {
                    print("Error fetching buildings: \(error)")
                }
            }
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
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
                    if let annotationTitle = view.annotation?.title, let buildingName = annotationTitle {
                        // Find the selected building from the buildings array
                        parent.selectedBuilding = parent.buildings.first(where: { $0.name == buildingName })
                    }
                }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse {
                manager.startUpdatingLocation()
            }
        }
        
        
    }
}

#Preview {
    SitesMapView()
}
