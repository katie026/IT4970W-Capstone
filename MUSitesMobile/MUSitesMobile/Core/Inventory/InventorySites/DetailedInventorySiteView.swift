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
    @Published var siteGroup: SiteGroup? = nil
    
    func loadBuilding(buildingId: String, completion: @escaping () -> Void) {
        Task {
            do {
                self.building = try await BuildingsManager.shared.getBuilding(buildingId: buildingId)
            } catch {
                print("Error loading building: \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    func loadInventoryTypes(inventoryTypeIds: [String]) {
        inventoryTypes = []
        keyTypes = []
        Task {
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
    
    func loadSiteGroup(buildingId: String, completion: @escaping () -> Void) {
        loadBuilding(buildingId: buildingId) {
            if let groupId = self.building?.siteGroupId {
                Task {
                    do {
                        self.siteGroup = try await SiteGroupManager.shared.getSiteGroup(siteGroupId: groupId)
                        completion()
                    } catch {
                        print("Error getting site group: \(error)")
                    }
                }
            } else {
                print("No siteGroupId from the building.")
            }
        }
    }
}

struct DetailedInventorySiteView: View {
    // View Models
    @StateObject private var viewModel = DetailedInventorySiteViewModel()
    @StateObject private var siteViewModel = DetailedSiteViewModel()
    // View Managing
    @Binding private var path: [Route]
    @StateObject var sheetManager = SheetManager()
    // Section Bools
    @State private var mapSectionExpanded: Bool = false
    @State private var pictureSectionExpanded: Bool = false
    // Passed-In Values
    let inventorySite: InventorySite
    
    init(path: Binding<[Route]>, inventorySite: InventorySite) {
        self._path = path
        self.inventorySite = inventorySite
    }
    
    var body: some View {
        // Content
        ScrollView {
            VStack(spacing: 14) {
                Header
                BasicInfo
                SubmitInventoryButton
                MapSection
                PictureSection
            }
        }
        .padding()
        // View Title
        .navigationTitle("Inventory: \(inventorySite.name ?? "N/A")")
        // On Appear
        .onAppear {
            Task {
                viewModel.loadSiteGroup(buildingId: inventorySite.buildingId ?? "") {}
                await viewModel.loadInventoryTypes(inventoryTypeIds: inventorySite.inventoryTypeIds ?? [])
                await siteViewModel.fetchSiteSpecificImageURLs(siteName: inventorySite.name ?? "Clark", category: "Inventory")
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
                Text("**Group:** \(viewModel.siteGroup?.name ?? "N/A")")
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
        .padding(.bottom, 10.0)
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
                        Label("Submit Inventory", systemImage: "pencil.and.list.clipboard")
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(10)
                }
            }
        }.padding(.trailing, 14)
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
                        // Button to Apple Maps
                        Button {
                            openMapDirections(to: coordinates)
                        } label: {
                            HStack {
                                Text("Get Directions")
                                Image(systemName: "figure.walk")
                                    .foregroundColor(Color.accentColor)
                            }
                        }
                        .padding(.top, 10)
                        
                        // Map Preview
                        SimpleMapView(
                            coordinates: coordinates,
                            label: self.inventorySite.name ?? "N/A"
                        )
                        .frame(height: 200)
                        .cornerRadius(8)
                    }
                },
                label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(UIColor.systemGray5))
                        HStack {
                            Label("Map", systemImage: "mappin.and.ellipse")
//                            Text("Map")
//                                .font(.title)
//                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(10)
                    }
                }
            )
            .padding(.top, 10.0)
        }
        .listRowBackground(Color(UIColor.systemGray5))
    }
        
    private var PictureSection: some View {
        // Picture Section
        Section() {
            DisclosureGroup(
                isExpanded: $pictureSectionExpanded,
                content: {
                    InventoryImageView(imageURLs: siteViewModel.inventoryImageURLs)
                        .padding(.vertical)
                },
                label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(UIColor.systemGray5))
                        HStack {
                            Label("Pictures", systemImage: "photo")
//                            Text("Pictures")
//                                .font(.title)
//                                .fontWeight(.semibold)
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
