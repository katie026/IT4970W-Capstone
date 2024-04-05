//
//  DetailedInventorySiteView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/6/24.
//

import SwiftUI
import MapKit

@MainActor
final class DetailedInventorySiteViewModel: ObservableObject {
    @Published var building: Building?
    @Published var inventoryTypes: [InventoryType] = []
    @Published var keyTypes: [KeyType] = []
    
    func loadBuilding(buildingId: String) async {
        do {
            self.building = try await BuildingsManager.shared.getBuilding(buildingId: buildingId)
        } catch {
            print("Error loading building: \(error.localizedDescription)")
        }
    }
    
    func loadInventoryTypes(inventoryTypeIds: [String]) async {
        inventoryTypes = []
        keyTypes = []
        
        do {
            for typeId in inventoryTypeIds {
                // try to get each
                let inventoryType = try await InventoryTypeManager.shared.getInventoryType(inventoryTypeId: typeId)
                inventoryTypes.append(inventoryType)
                
                // if keyTypeId is not nil
                if let keyTypeId = inventoryType.keyTypeId {
                    let keyType = try await KeyTypeManager.shared.getKeyType(keyTypeId: keyTypeId)
                    keyTypes.append(keyType)
                } else {
                    print("Warning: keyTypeId is nil for inventoryType with ID \(inventoryType.id)")
                }
            }
        } catch {
            print("Error loading inventory types: \(error.localizedDescription)")
        }
    }
}

struct DetailedInventorySiteView: View {
    // View Model
    @StateObject private var viewModel = DetailedInventorySiteViewModel()
    // View Managing
    @Binding private var path: [Route]
    @StateObject var sheetManager = SheetManager()
    // Section Bools
    @State private var mapSectionExpanded: Bool = true
    @State private var pictureSectionExpanded: Bool = true
    // Passed-In Values
    let inventorySite: InventorySite
    
    init(path: Binding<[Route]>, inventorySite: InventorySite) {
        self._path = path
        self.inventorySite = inventorySite
    }
    
    var body: some View {
        // Content
        ScrollView {
            VStack(spacing: 16) {
                Header
                BasicInfo
                SubmitInventoryButton
                MapSection
                PictureSection
            }
            .padding()
        }
        // View Title
        .navigationTitle("Inventory: \(inventorySite.name ?? "N/A")")
        // On Appear
        .onAppear {
            Task {
                await viewModel.loadBuilding(buildingId: inventorySite.buildingId ?? "")
                await viewModel.loadInventoryTypes(inventoryTypeIds: inventorySite.inventoryTypeIds ?? [])
            }
        }
    }
    
    private var Header: some View {
        HStack {
            Text(inventorySite.name ?? "N/A")
                .font(.title2)
                .fontWeight(.semibold)
            Spacer()
        }.padding([.leading, .bottom, .trailing], 5.0)
    }
    
    private var BasicInfo: some View {
        // Basic Info
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("**Group:** \(viewModel.building?.siteGroup ?? "N/A")")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text("**Building:** \(viewModel.building?.name ?? "N/A")")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text("**Type:** \(viewModel.inventoryTypes.map { $0.name }.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text("**Keys:** \(viewModel.keyTypes.map { $0.name }.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.horizontal, 15.0)
    }
    
    private var SubmitInventoryButton: some View {
        // Submit Inventory Button
        VStack {
            Button (action: {
                path.append(Route.inventorySubmission(inventorySite))
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color(UIColor.systemGray5))
                    HStack {
                        Text("Submit Inventory Entry")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(10)
                }
            }
        }
    }
    
    private var MapSection: some View {
        let coordinates: CLLocationCoordinate2D
        
        if let buildingCoordinates = viewModel.building?.coordinates {
            coordinates = CLLocationCoordinate2D(latitude: buildingCoordinates.latitude, longitude: buildingCoordinates.longitude)
        } else {
            coordinates = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        }
        
        // Map Section
        return Section() {
            DisclosureGroup(
                isExpanded: $mapSectionExpanded,
                content: {
                    VStack {
                        // Map Preview
                        SimpleMapView(
                            coordinates: coordinates,
                            label: self.inventorySite.name ?? "N/A"
                        )
                        .frame(height: 200)
                        .cornerRadius(8)
                        .padding(.top, 10)
                        
                        // Button to Apple Maps
                        Button("Get Directions") {
                            openMapDirections(to: coordinates)
                        }
                    }
                },
                label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(UIColor.systemGray5))
                        HStack {
                            Text("Map")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(10)
                    }
                }
            )
            .padding(.top, 10.0)
        }
    }
        
    private var PictureSection: some View {
        // Picture Section
        Section() {
            DisclosureGroup(
                isExpanded: $pictureSectionExpanded,
                content: {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<3) { _ in
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                    .padding(4)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.top, 10)
                },
                label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(UIColor.systemGray5))
                        HStack {
                            Text("Pictures")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(10)
                    }
                }
            )
            .padding(.top, 10.0)
        }
    }
    
    func openMapDirections(to destinationCoordinate: CLLocationCoordinate2D) {
        // specify destination
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        
        // define destination name
        mapItem.name = (inventorySite.name ?? "N/A")
        
        // launch Apple Maps with walking directions
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
}


//MARK: Previews
private struct DetailedInventorySitePreview: View {
    @State private var path: [Route] = []
    
    private var inventorySite: InventorySite = InventorySite(
        id: "TzLMIsUbadvLh9PEgqaV",
        name: "BCC 122",
        buildingId: "yXT87CrCZCoJVRvZn5DC",
        inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]
    )
    
    var body: some View {
        NavigationStack (path: $path) {
            Button ("Hello World") {
                path.append(Route.detailedInventorySite(inventorySite))
            }
            .navigationDestination(for: Route.self) { view in
                switch view {
                case .inventorySitesList:
                    InventorySitesView()
                case .detailedInventorySite(let inventorySite): DetailedInventorySiteView(path: $path, inventorySite: inventorySite)
                case .inventorySubmission(let inventorySite):
                    InventorySubmissionView(path: $path, inventorySite: inventorySite)
                        .environmentObject(SheetManager())
                case .inventoryChange(let inventorySite):
                    InventoryChangeView(path: $path, inventorySite: inventorySite)
                }
            }
        }
        .onAppear {
            path.append(Route.detailedInventorySite(inventorySite))
        }
    }
}

    
#Preview {
    DetailedInventorySitePreview()
}
