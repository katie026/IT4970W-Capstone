//
//  DetailedInventorySiteView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/6/24.
//

import SwiftUI

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
            // Backround
            VStack {
                // Gradient rectangle
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .green, location: 0.0),
                                .init(color: .clear, location: 1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 100)
                Spacer()
            }
            
            // Text Content
            VStack(alignment: .leading) {
                // Header
                HStack {
                    Text(inventorySite.name ?? "N/A")
                        .font(.system(size: 25))
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                // Basic Info
                VStack(alignment: .leading, spacing: 4) {
                    Text("**Group:** \(viewModel.building?.siteGroup ?? "N/A")")
                    Text("**Building:** \(viewModel.building?.name ?? "N/A")")
                    Text("**Types:** \(viewModel.inventoryTypes.map { $0.name }.joined(separator: ", "))")
                    Text("**Keys:** \(viewModel.keyTypes.map { $0.name }.joined(separator: ", "))")
                }
                .padding(.top, 20)
                
                // Submit Inventory
                HStack {
                    Button(action: {
                        // button action
                    }) {
                        Text("Submit Inventory")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                    }
                    Spacer()
                }
                .padding(.top, 30.0)
                
                // Map
                
                // Pictures
                
                Spacer()
            }
            .padding(.leading, 20)
            .navigationTitle("Inventory Site")
            .onAppear {
                Task {
                    await viewModel.loadBuilding(buildingId: inventorySite.buildingId ?? "")
                    await viewModel.loadInventoryTypes(inventoryTypeIds: inventorySite.inventoryTypeIds ?? [])
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailedInventorySiteView(inventorySite: InventorySite(id: "TzLMIsUbadvLh9PEgqaV", name: "BCC 122", buildingId: "yXT87CrCZCoJVRvZn5DC", inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]))
    }
}
