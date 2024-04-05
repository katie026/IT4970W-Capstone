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
    @Published var inventorySite: InventorySite? = nil // will be passed in from the View
    @Published var newSupplyCounts: [SupplyCount] = []
    @Published var levelSupplyCounts: [SupplyCount] = [] // this is only ot hold updated levels
    @Published var inventoryEntryType: InventoryEntryType = .Check
    @Published var comments: String = ""
    @Published var destinationSite: InventorySite = InventorySite(
        id: "",
        name: "N/A",
        buildingId: "",
        inventoryTypeIds: [""]
    )
    
    // Inventory Sites
    @Published var inventorySites: [InventorySite] = []

    func getSupplyTypes() {
        Task {
            self.supplyTypes = try await SupplyTypeManager.shared.getAllSupplyTypes(descending: false)
        }
    }

    func getSupplyCounts(inventorySiteId: String) {
        Task {
            self.supplyCounts = try await SupplyCountManager.shared.getAllSupplyCountsBySite(siteId: inventorySiteId)

            // Make a copy of each SupplyCount object and assign to newSupplyCounts
            self.newSupplyCounts = self.supplyCounts.map { $0.copy() }
            // Make a copy of each SupplyCount object and assign to levelSupplyCounts
            self.levelSupplyCounts = self.supplyCounts.map { $0.copy() }
        }
    }

    func createNewSupplyCount(inventorySiteId: String, supplyTypeId: String, completion: @escaping () -> Void) {
        Task {
            do {
                // create new document and get id from Firestore
                let newId = try await SupplyCountManager.shared.getNewSupplyCountId()

                // create a new SupplyCount struct
                let newSupplyCount = SupplyCount(
                    id: newId, // generated a unique ID
                    inventorySiteId: inventorySiteId,
                    supplyTypeId: supplyTypeId,
                    countMin: 0,
                    count: 0,
                    level: 0
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

    func submitSupplyCounts(supplyCounts: [SupplyCount], completion: @escaping () -> Void) {
        Task {
            do {
                try await SupplyCountManager.shared.updateSupplyCounts(supplyCounts)
                // Call the completion handler upon successful creation
                completion()
                print("Updated SupplyCount batch (\(supplyCounts.count)) in Firestore.")
            } catch {
                print("Error updating SupplyCounts: \(error)")
            }
        }
    }
    
    func getInventorySites(completion: @escaping () -> Void) {
        Task {
            self.inventorySites = try await InventorySitesManager.shared.getAllInventorySites(descending: false)
            completion()
        }
    }
    
//    // modify newSupplyCount
//    func mergeSupplyCounts(supplyCounts: [SupplyCount], newSupplyCounts: inout [SupplyCount]) {
//        // merge supplyCounts into newSupplyCounts if supplyType doesn't already exist
//        for supplyCount in supplyCounts {
//            // if the supplyType doesn't already exist in newSupplyCounts
//            if !newSupplyCounts.contains(where: { $0.supplyTypeId == supplyCount.supplyTypeId }) {
//                // add the supplyCount to newSupplyCounts
//                newSupplyCounts.append(supplyCount)
//            }
//        }
//    }
    
    // return new array
    func mergeSupplyCounts(originalSupplyCounts: [SupplyCount], newSupplyCounts: [SupplyCount]) -> [SupplyCount] {
        // add any SupplyCounts from supplyCounts into newSupplyCounts it doesn't already have the SupplyType
        
        // start with all the newSupplyCounts
        var mergedCounts = newSupplyCounts
        
        // check each SupplyCount in originalSupplyCounts
        for supplyCount in originalSupplyCounts {
            // if mergedCounts doesn't already have that SupplyType
            if !mergedCounts.contains(where: { $0.supplyTypeId == supplyCount.supplyTypeId }) {
                // add the SupplyCount to mergedCounts
                mergedCounts.append(supplyCount)
            }
        }
        return mergedCounts
    }
    
    func createInventoryEntry(supplyCounts: [SupplyCount], completion: @escaping () -> Void) {
        Task {
            do {
                // create new document and get id from Firestore
                let inventoryEntryId = try await InventoryEntriesManager.shared.getNewInventoryEntryId()
                
                // get current user
                let user = try AuthenticationManager.shared.getAuthenticatedUser()
                
                // alter comments if needed
                if inventoryEntryType == .MoveTo {
                    comments = "Moved supplies to \(destinationSite.name ?? "N/A"). " + comments
                } else if (inventoryEntryType == .MovedFrom) {
                    comments = "Moved supplies from \(destinationSite.name ?? "N/A"). " + comments
                }
                
                // create a new InventoryEntry struct for the current site
                let inventoryEntry = InventoryEntry(
                    id: inventoryEntryId, // generated a unique ID
                    inventorySiteId: self.inventorySite?.id,
                    timestamp: Date(),
                    type: self.inventoryEntryType,
                    userId: user.uid,
                    comments: self.comments
                )
                
                // update inventory entry document in Firestore
                try await InventoryEntriesManager.shared.createInventoryEntry(inventoryEntry: inventoryEntry)
                print("Created inventory entry: \(inventoryEntryId).")
                
                // create a new SupplyEntry for each SupplyType
                for supplyType in self.supplyTypes {
                    // find the SupplyCount for this SupplyType (where .supplyTypeId == supplyType.id)
                    if let supplyCount = supplyCounts.first(where: { $0.supplyTypeId == supplyType.id }) {
                        // create new document and get id from Firestore
                        let supplyEntryId = try await SupplyEntriesManager.shared.getNewSupplyEntryId()
                        
                        // SupplyCount.count
                        let supplyEntry = SupplyEntry(
                            id: supplyEntryId, // use generated id
                            inventoryEntryId: inventoryEntryId, // attach to this inventory entry
                            supplyTypeId: supplyType.id, // per supply type
                            count: supplyCount.count,
                            level: supplyCount.level,
                            used: supplyCount.usedCount
                        )
                        
                        // update supply entry document in Firestore
                        try await SupplyEntriesManager.shared.createSupplyEntry(supplyEntry: supplyEntry)
                    }
                }

                // call completion handler upon successful creation
                completion()
            } catch {
                print("Error creating new inventory entry: \(error)")
            }
        }
    }
    
    func removeMatchingSupplyCounts(oldCounts: [SupplyCount], newCounts: [SupplyCount]) -> [SupplyCount] {
        print("Counts before: \(newCounts.count)")
        print("Removing matches now...")
        // remove SupplyCounts from newCounts where supplyId, count, & level match those in oldCounts
        // check each newSupplyCount
        let newCounts = newCounts.filter { newCount in
            // check each old supplyCount
            !oldCounts.contains { oldCount in
                // don't include counts where the supplyType, count, and level are the same
                oldCount.supplyTypeId == newCount.supplyTypeId && oldCount.count == newCount.count && oldCount.level == newCount.level
            }
        }
        print("Counts after: \(newCounts.count)")
        return newCounts
    }
    
    func submitAnInventoryEntry(completion: @escaping () -> Void) {
        // if type is .Check (newSupplyCounts is empty)
        if (inventoryEntryType == .Check) {
            // send original SupplyCounts (with new levels) to Firestore
            submitSupplyCounts(supplyCounts: self.supplyCounts) {}
            
            // create InventoryEntry struct add to Firestore
            // send original supplyCounts (with new levels)
            createInventoryEntry(supplyCounts: self.supplyCounts) {
                // call completion after entry is created
                completion()
            }
        // else if type is .Fix, .Delivery, or .MovedFrom (newSupplyCounts only includes updated supplyTypes)
        } else if (inventoryEntryType == .Fix || inventoryEntryType == .Delivery || inventoryEntryType == .MovedFrom) {
            // send updated SupplyCounts to Firestore
            submitSupplyCounts(supplyCounts: self.newSupplyCounts) {}
            
            // create new list of SupplyCounts by merging supplyCounts and newSupplyCounts
            let allSupplyCounts = mergeSupplyCounts(originalSupplyCounts: self.supplyCounts, newSupplyCounts: self.newSupplyCounts)
            
            // create InventoryEntry struct and add to Firestore
            // send merged SupplyCounts (with new levels)
            createInventoryEntry(supplyCounts: allSupplyCounts) {
                // call completion after entry is created
                completion()
            }
        // else type is .MoveTo or .Use (newSupplyCounts includes all supplyTypes with .usedCount property)
        } else {
            // create new list of only SupplyCounts that reported used/moved
            let updates = self.newSupplyCounts.filter { $0.usedCount != 0 }
            
            // send updated SupplyCounts to Firestore
            submitSupplyCounts(supplyCounts: updates) { }
            
            // create InventoryEntry struct and add to Firestore
            // send all newSupplyCounts (with new levels)
            createInventoryEntry(supplyCounts: self.newSupplyCounts) {
                // call completion after batch update
                completion()
            }
        }
    }
}
