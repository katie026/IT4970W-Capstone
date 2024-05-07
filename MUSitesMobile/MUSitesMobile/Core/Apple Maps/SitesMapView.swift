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
    @State private var selectedSiteGroup: SiteGroup? = nil
    @State private var siteGroupChosen: String? = nil
    @State private var allSiteGroups: [SiteGroup] = []
    
    var body: some View {
        ZStack {
            MapView(selectedBuilding: $selectedBuilding, selectedSiteGroup: $selectedSiteGroup)
                .edgesIgnoringSafeArea(.top)
            
            VStack() {
                HStack {
                    Menu {
                        Picker("Site Group", selection: $selectedSiteGroup) {
                            Text("All").tag(nil as SiteGroup?)
                            ForEach(allSiteGroups, id: \.self) { group in
                                Text(group.name).tag(group as SiteGroup?)
                            }
                        }.multilineTextAlignment(.leading)
                    } label: {
                        Text("**Site Group:** \(selectedSiteGroup?.name ?? "All")")
                            .padding(10) // Adjust the padding size here
                            .background(Color.accentColor)
                            .cornerRadius(10) // Adjust the corner radius as needed
                            .foregroundColor(Color("AccentContrastColor"))
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationTitle("Map")
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
        .onAppear{
            getSiteGroups() {}
        }
    }
    
    func getSiteGroups(completion: @escaping () -> Void) {
        Task {
            do {
                self.allSiteGroups = try await SiteGroupManager.shared.getAllSiteGroups(descending: nil)
                completion()
            } catch {
                print("Error getting site groups: \(error)")
            }
        }
    }
}




struct MapView: UIViewRepresentable {
    @State private var userTrackingMode: MKUserTrackingMode = .follow
    @Binding var selectedBuilding: Building?
    @Binding var selectedSiteGroup: SiteGroup?
    
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
        let selectedSiteGroupId = selectedSiteGroup?.id
        
        Task {
            do {
                let fetchedBuildings = try await BuildingsManager.shared.getAllBuildings(descending: nil, group: selectedSiteGroupId)
                DispatchQueue.main.async {
                    completion(fetchedBuildings)
                }
            } catch {
                print("Error fetching buildings: \(error)")
            }
        }
    }
    
    private func addAnnotations(to mapView: MKMapView) {
        let selectedSiteGroupId = selectedSiteGroup?.id
        mapView.removeAnnotations(mapView.annotations)
        
        for building in buildings {
            if let coordinates = building.coordinates, selectedSiteGroup == nil || building.siteGroupId == selectedSiteGroupId {
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
    TabView {
        NavigationStack {
            SitesMapView()
        }
        .tabItem {
            Image(systemName: "map")
            Text("Map")
        }
    }
}

