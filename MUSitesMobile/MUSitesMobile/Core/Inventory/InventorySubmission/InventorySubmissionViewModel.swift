//
//  InventorySubmissionViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/1/24.
//

import Foundation

@MainActor
final class InventorySubmissionViewModel: ObservableObject {
    // Supply Values
    @Published var supplyTypes: [SupplyType] = []
    @Published var supplyCounts: [SupplyCount] = []
    
    // Inventory Entry Default Values
    @Published var newSupplyCounts: [SupplyCount] = []
    @Published var inventoryEntryType: InventoryEntryType = .Check
    @Published var comments: String = ""
    @Published var destinationSite: InventorySite = InventorySite(
        id: "",
        name: "Empty",
        buildingId: "",
        inventoryTypeIds: [""]
    )
    
    // Inventory Sites
    @Published var inventorySites: [InventorySite] = []

    func getSupplyTypes() {
        Task {
            self.supplyTypes = try await SupplyTypeManager.shared.getAllSupplyTypes(descending: true)
        }
    }

    func getSupplyCounts(inventorySiteId: String) {
        Task {
            self.supplyCounts = try await SupplyCountManager.shared.getAllSupplyCountsBySite(siteId: inventorySiteId)

            // Make a copy of each SupplyCount object and assign to newSupplyCounts
            self.newSupplyCounts = self.supplyCounts.map { $0.copy() }
        }
    }

    func createNewSupplyCount(inventorySiteId: String, supplyTypeId: String, completion: @escaping () -> Void) {
        Task {
            do {
                // create new document and get id from Firestore
                let newId = try await SupplyCountManager.shared.getNewSupplyCountId()

                // create a new SupplyCount struct
                let newSupplyCount = SupplyCount(
                    id: newId, // Generate a unique ID
                    inventorySiteId: inventorySiteId,
                    supplyTypeId: supplyTypeId,
                    countMin: 0,
                    count: 0
                )

                // update document with new SupplyCount
                try await SupplyCountManager.shared.createSupplyCount(supplyCount: newSupplyCount)

                // Call the completion handler upon successful creation
                completion()
            } catch {
                print("Error creating new supply count: \(error)")
            }
        }
    }

    func submitSupplyCounts(completion: @escaping () -> Void) {
        Task {
            do {
                try await SupplyCountManager.shared.updateSupplyCounts(newSupplyCounts)
                // Call the completion handler upon successful creation
                completion()
                print("Updated SupplyCount batch in Firestore")
            } catch {
                print("Error creating new supply count: \(error)")
            }
        }
    }
    
    func getInventorySites(completion: @escaping () -> Void) {
        Task {
            self.inventorySites = try await InventorySitesManager.shared.getAllInventorySites(descending: false)
            completion()
        }
    }
    
    func submitAnInventoryEntry() {
        // remove newSupplyCounts where .usedCount == 0
        
        // update SupplyCounts in Firestore
        submitSupplyCounts() {}
        
        // create InventoryEntry struct
        
        // create InventoryEntry in Firestore
        
        // if entry type is .Move
        return
    }
}
