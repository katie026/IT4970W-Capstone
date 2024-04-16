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
    @State private var siteGroupChosen: String? = nil
    
    
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
                                siteGroupChosen = "All"
                            }) {
                                Text("All")
                            }

                            //TODO: get site_groups from firestore
                            Button(action: {
                                selectedSiteGroup = "LM0MN0spXlHfd2oZSahO"
                                siteGroupChosen = "R1"
                            }) {
                                Text("R1")
                            }
                            
                            Button(action: {
                                selectedSiteGroup = "gkRTxs7OyARmxGHHPuMV"
                                siteGroupChosen = "R1"

                            }) {
                                Text("G1")
                            }
                            
                            Button(action: {
                                selectedSiteGroup = "kxeYimfnOx1YnB9TVXp9"
                                siteGroupChosen = "R1"
                            }) {
                                Text("G2")
                            }
                            
                            Button(action: {
                                selectedSiteGroup = "zw1TFIf7KQxMNrThdfD1"
                                siteGroupChosen = "R1"

                            }) {
                                Text("G3")
                            }
                            Button(action: {
                                selectedSiteGroup = ""
                                siteGroupChosen = "R1"
                            }) {
                                Text("None")
                            }
                            
                            // Add more site groups as needed
                        } label: {
                            Text("Select Site Group")
                                .padding(10) // Adjust the padding size here
                                .background(Color.yellow)
                                .cornerRadius(10) // Adjust the corner radius as needed
                                .foregroundColor(.black) // Set text color to black
                        }

                        Text("Selected Option: \(selectedSiteGroup ?? "None")")
                            .padding(5) // Adjust the padding size here
                            .background(Color.black)
                            .cornerRadius(5) // Adjust the corner radius as needed
                            .foregroundColor(.yellow) // Set text color to yellow
                            .font(.system(size: 14)) // Set a smaller font size
                            .padding(10) // Adjust the padding size here
                        
                    }
                }
                .navigationTitle("Map")
                .navigationBarHidden(true)
                .background(
                    //TODO: update to NagivationStack? Renable link to in BuildingDetailView
                    NavigationLink(
                        destination: selectedBuilding != nil ? BuildingDetailView(building: selectedBuilding!) : nil,
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
            if let coordinates = building.coordinates, selectedSiteGroup == nil || building.siteGroupId == selectedSiteGroup {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                annotation.subtitle = building.siteGroupId
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

