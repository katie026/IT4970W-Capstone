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
    @State private var selectedSiteGroup: String? = nil
    
    
    var body: some View {
            NavigationView {
                ZStack {
                    MapView(selectedBuilding: $selectedBuilding, selectedSiteGroup: $selectedSiteGroup)
                        .edgesIgnoringSafeArea(.top)
                    
                    VStack {
                        Spacer()
                        
                        
                        Menu {
                            Button(action: {
                                selectedSiteGroup = nil
                            }) {
                                Text("All")
                            }
                            
                            Button(action: {
                                selectedSiteGroup = "R1"
                            }) {
                                Text("R1")
                            }
                            
                            Button(action: {
                                selectedSiteGroup = "G1"
                            }) {
                                Text("G1")
                            }
                            
                            Button(action: {
                                selectedSiteGroup = "G2"
                            }) {
                                Text("G2")
                            }
                            
                            Button(action: {
                                selectedSiteGroup = "G3"
                            }) {
                                Text("G3")
                            }
                            Button(action: {
                                selectedSiteGroup = ""
                            }) {
                                Text("None")
                            }
                            
                            // Add more site groups as needed
                        } label: {
                            Text("Select Site Group")
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
    @Binding var selectedSiteGroup: String?
    
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
            if let coordinates = building.coordinates, selectedSiteGroup == nil || building.siteGroup == selectedSiteGroup {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                annotation.subtitle = building.siteGroup
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

