//
//  DetailedInventorySiteViewModel.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/26/24.
//

import Foundation

@MainActor
final class DetailedInventorySiteViewModel: ObservableObject {
    @Published var inventorySite: InventorySite?
    @Published var building: Building?
    @Published var inventoryTypes: [InventoryType] = []
    @Published var keyTypes: [KeyType] = []
    
    func loadInventorySite(inventorySiteId: String) async {
        do {
            self.inventorySite = try await InventorySitesManager.shared.getInventorySite(inventorySiteId: inventorySiteId)
            await loadBuilding(buildingId: inventorySite?.buildingId ?? "")
            await loadInventoryTypes(inventoryTypeIds: inventorySite?.inventoryTypeIds ?? [])
        } catch {
            print("Error loading inventory site: \(error.localizedDescription)")
        }
    }
    
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
                let inventoryType = try await InventoryTypeManager.shared.getInventoryType(inventoryTypeId: typeId)
                inventoryTypes.append(inventoryType)
                
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
