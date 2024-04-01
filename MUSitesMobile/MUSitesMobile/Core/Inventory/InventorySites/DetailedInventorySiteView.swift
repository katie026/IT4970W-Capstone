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
    @StateObject private var viewModel = DetailedInventorySiteViewModel()
    @State private var mapSectionExpanded: Bool = true
    @State private var pictureSectionExpanded: Bool = true
    
    private var inventorySite: InventorySite
    
    init(inventorySite: InventorySite) {
        self.inventorySite = inventorySite
    }
    
    var body: some View {
        // Content
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack {
                    HStack {
                        Text("Inventory")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        Text(inventorySite.name ?? "N/A")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .padding([.leading, .bottom, .trailing], 5.0)
                
                // Site Information
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
                
                // Submit Inventory Button
                HStack {
                    NavigationLink(destination: InventorySubmissionView(inventorySite: inventorySite))
                    {
                        HStack {
                            Text("Submit Inventory Entry")
                                .padding(10)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                    .isDetailLink(false)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(8)
                    
                    Spacer()
                }
                
                // Map
                Section() {
                    DisclosureGroup(
                        isExpanded: $mapSectionExpanded,
                        content: {
                            if let buildingCoordinates = viewModel.building?.coordinates {
                                SimpleMapView(
                                    coordinates: CLLocationCoordinate2D(
                                        latitude: buildingCoordinates.latitude,
                                        longitude: buildingCoordinates.longitude
                                    ),
                                    label: self.inventorySite.name ?? "N/A"
                                )
                                .frame(height: 200)
                                .cornerRadius(8)
                                .padding(.top, 10)
                            } else {
                                SimpleMapView(
                                    coordinates: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                                    label: self.inventorySite.name ?? "N/A"
                                )
                                .frame(height: 200)
                                .cornerRadius(8)
                                .padding(.top, 10)
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
                
                // Pictures
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
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(inventorySite.name ?? "N/A")
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadBuilding(buildingId: inventorySite.buildingId ?? "")
                await viewModel.loadInventoryTypes(inventoryTypeIds: inventorySite.inventoryTypeIds ?? [])
            }
        }
    }
}
    
    #Preview {
        NavigationStack {
            DetailedInventorySiteView(inventorySite: InventorySite(id: "TzLMIsUbadvLh9PEgqaV", name: "GO BCC", buildingId: "yXT87CrCZCoJVRvZn5DC", inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]))
        }
    }

