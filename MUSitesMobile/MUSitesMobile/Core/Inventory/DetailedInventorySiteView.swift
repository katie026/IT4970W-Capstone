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
    
    private var inventorySite: InventorySite
    
    init(inventorySite: InventorySite) {
        self.inventorySite = inventorySite
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [.green, .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 16) {
                // Header
                Text("Inventory")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(inventorySite.name ?? "N/A")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Site Information
                VStack(alignment: .leading, spacing: 8) {
                    Text("Group: \(viewModel.building?.siteGroup ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Building: \(viewModel.building?.name ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Type: \(viewModel.inventoryTypes.map { $0.name }.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Keys: \(viewModel.keyTypes.map { $0.name }.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Submit Inventory Button
                Button(action: {
                }) {
                    Text("Submit Inventory Entry")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                // Map
                SitesMap()
                    .frame(height: 200)
                    .cornerRadius(8)
                
                // Pictures
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
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Inventory Site")
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
            DetailedInventorySiteView(inventorySite: InventorySite(id: "TzLMIsUbadvLh9PEgqaV", name: "Strickland 222", buildingId: "yXT87CrCZCoJVRvZn5DC", inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]))
        }
    }

