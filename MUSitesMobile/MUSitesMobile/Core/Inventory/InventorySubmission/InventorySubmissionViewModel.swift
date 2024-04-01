//
//  InventorySubmissionViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/1/24.
//

import Foundation

@MainActor
final class InventorySubmissionViewModel: ObservableObject {
    @Published var supplyTypes: [SupplyType] = []
    @Published var supplyCounts: [SupplyCount] = []
    @Published var newSupplyCounts: [SupplyCount] = []
    @Published var inventoryEntryType: InventoryEntryType = InventoryEntryType.Check // Check or Fix
    @Published var comments: String = ""

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

                print("created new Supply doc in Firestore")
            } catch {
                print("Error creating new supply count: \(error)")
            }
        }
    }

    func submitSupplyCounts(completion: @escaping () -> Void) {
        print("supplyCounts submitted!")
        Task {
            do {
                try await SupplyCountManager.shared.updateSupplyCounts(newSupplyCounts)
                // Call the completion handler upon successful creation
                completion()

                print("Updated supplies doc in Firestore")
            } catch {
                print("Error creating new supply count: \(error)")
            }
        }
    }
}
