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
                    id: newId, // generated a unique ID
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

    func submitSupplyCounts(supplyCounts: [SupplyCount], completion: @escaping () -> Void) {
        Task {
            do {
                try await SupplyCountManager.shared.updateSupplyCounts(supplyCounts)
                // Call the completion handler upon successful creation
                completion()
                print("Updated SupplyCount batch (\(supplyCounts.count) in Firestore")
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
                let entryId = try await InventoryEntriesManager.shared.getNewInventoryEntryId()
                
                // get current user
                let user = try AuthenticationManager.shared.getAuthenticatedUser()
                
                //TODO: alter comments if needed
                if inventoryEntryType == .MoveTo {
                    comments = "Moved supplies to \(String(describing: destinationSite.name)). " + comments
                } else if (inventoryEntryType == .MovedFrom) {
                    comments = "Moved supplies from \(String(describing: destinationSite.name)). " + comments
                }
                
                // Get supply data:
                // colorTabloid
                let colorTabloid = supplyCounts.first(where: { $0.supplyTypeId == InventoryEntry.CodingKeys.colorTabloid.rawValue })
                // bwTabloid
                let bwTabloid = supplyCounts.first(where: { $0.supplyTypeId == InventoryEntry.CodingKeys.bwTabloid.rawValue })
                // threeMSpray
                let threeMSpray = supplyCounts.first(where: { $0.supplyTypeId == InventoryEntry.CodingKeys.threeMSpray.rawValue })
                // bwPaper
                let bwPaper = supplyCounts.first(where: { $0.supplyTypeId == InventoryEntry.CodingKeys.bwPaper.rawValue })
                // colorPaper
                let colorPaper = supplyCounts.first(where: { $0.supplyTypeId == InventoryEntry.CodingKeys.colorPaper.rawValue })
                // wipes
                let wipes = supplyCounts.first(where: { $0.supplyTypeId == InventoryEntry.CodingKeys.wipes.rawValue })
                // paperTowel
                let paperTowel = supplyCounts.first(where: { $0.supplyTypeId == InventoryEntry.CodingKeys.paperTowel.rawValue })
                
                // create a new InventoryEntry struct for the current site
                let entry = InventoryEntry(
                    id: entryId, // generated a unique ID
                    inventorySiteId: inventorySite?.id,
                    timestamp: Date(),
                    type: inventoryEntryType,
                    userId: user.uid,
                    colorTabloid: colorTabloid?.count,
                    bwTabloid: bwTabloid?.count,
                    threeMSpray: threeMSpray?.count,
                    bwPaper: bwPaper?.count,
                    colorPaper: colorPaper?.count,
                    wipes: wipes?.count,
                    paperTowel: paperTowel?.count
                )
                
                // update document in Firestore
                try await InventoryEntriesManager.shared.createInventoryEntry(inventoryEntry: entry)
                print("Created entry at origin site.")
                
//                // SUBMIT ANOTHER ENTRY if entryType is .Move
//                if inventoryEntryType == .Move {
//                    // create another new document and get id from Firestore
//                    let destEntryId = try await InventoryEntriesManager.shared.getNewInventoryEntryId()
//                    
//                    // get the current SupplyCounts from the destination site
//                    let destinationCounts = try await SupplyCountManager.shared.getAllSupplyCountsBySite(siteId: self.destinationSite.id)
//                    
//                    // Get supply data:
//                    // colorTabloid
//                    let colorTabloid_dest = calculateNewDestinationCount(supplyId: InventoryEntry.CodingKeys.colorTabloid.rawValue, destCounts: destinationCounts, originCounts: supplyCounts)
//                    // bwTabloid
//                    let bwTabloid_dest = calculateNewDestinationCount(supplyId: InventoryEntry.CodingKeys.bwTabloid.rawValue, destCounts: destinationCounts, originCounts: supplyCounts)
//                    // threeMSpray
//                    let threeMSpray_dest = calculateNewDestinationCount(supplyId: InventoryEntry.CodingKeys.threeMSpray.rawValue, destCounts: destinationCounts, originCounts: supplyCounts)
//                    // bwPaper
//                    let bwPaper_dest = calculateNewDestinationCount(supplyId: InventoryEntry.CodingKeys.bwPaper.rawValue, destCounts: destinationCounts, originCounts: supplyCounts)
//                    // colorPaper
//                    let colorPaper_dest = calculateNewDestinationCount(supplyId: InventoryEntry.CodingKeys.colorPaper.rawValue, destCounts: destinationCounts, originCounts: supplyCounts)
//                    // wipes
//                    let wipes_dest = calculateNewDestinationCount(supplyId: InventoryEntry.CodingKeys.wipes.rawValue, destCounts: destinationCounts, originCounts: supplyCounts)
//                    // paperTowel
//                    let paperTowel_dest = calculateNewDestinationCount(supplyId: InventoryEntry.CodingKeys.paperTowel.rawValue, destCounts: destinationCounts, originCounts: supplyCounts)
//                    
//                    // create a new InventoryEntry struct for the destination site
//                    let destEntry = InventoryEntry(
//                        id: destEntryId, // generated a unique ID
//                        inventorySiteId: destinationSite.id,
//                        timestamp: Date(),
//                        type: inventoryEntryType,
//                        userId: user.uid,
//                        colorTabloid: colorTabloid_dest,
//                        bwTabloid: bwTabloid_dest,
//                        threeMSpray: threeMSpray_dest,
//                        bwPaper: bwPaper_dest,
//                        colorPaper: colorPaper_dest,
//                        wipes: wipes_dest,
//                        paperTowel: paperTowel_dest
//                    )
//                    
//                    // update document with new InventoryEntry
//                    try await InventoryEntriesManager.shared.createInventoryEntry(inventoryEntry: destEntry)
//                    print("Created entry at destination site.")
//                    
//                    // update supplycounts at destination here
//                }

                // call completion handler upon successful creation
                completion()
            } catch {
                print("Error creating new inventory entry: \(error)")
            }
        }
    }
    
    private func calculateNewDestinationCount(supplyId: String, destCounts: [SupplyCount], originCounts: [SupplyCount]) -> Int? {
        var newDestinationCount: Int?
        
        let destinationCount = destCounts.first(where: { $0.supplyTypeId == supplyId })?.count
        let originUsedCount = originCounts.first(where: { $0.supplyTypeId == supplyId })?.usedCount
        
        // Both destinationCount and originUsedCount are not nil
        if let destinationCount = destinationCount,
           let originUsedCount = originUsedCount {
            newDestinationCount = destinationCount + originUsedCount
        // Only destinationCount is not nil
        } else if let destinationCount = destinationCount {
            newDestinationCount = destinationCount
        // Only originUsedCount is not nil
        } else if let originUsedCount = originUsedCount {
            newDestinationCount = originUsedCount
        // Both destinationCount and originUsedCount are nil
        } else {
            newDestinationCount = nil
        }
        
        return newDestinationCount
    }
    
    func removeMatchingCountsFromNewSupplyCounts() {
        print("removing matches")
        // Remove SupplyCounts from newSupplyCounts where supplyId and count match those in supplyCounts
        newSupplyCounts = newSupplyCounts.filter { newSupplyCount in
            // check each newSupplyCount
            !supplyCounts.contains { supplyCount in
                // check each old supplyCount
                
                // don't include counts where the supplyType & count are the same
                supplyCount.supplyTypeId == newSupplyCount.supplyTypeId && supplyCount.count == newSupplyCount.count
            }
        }
    }
    
    func submitAnInventoryEntry(completion: @escaping () -> Void) {
        // if type is .Check (newSupplyCounts is empty)
        if (inventoryEntryType == .Check) {
            // create InventoryEntry struct from original supplyCounts and add to Firestore
            createInventoryEntry(supplyCounts: supplyCounts) {
                // call completion after entry is created
                completion()
            }
        // else if type is .Fix, .Delivery, or .MovedFrom (newSupplyCounts only includes updated supplyTypes)
        } else if (inventoryEntryType == .Fix || inventoryEntryType == .Delivery || inventoryEntryType == .MovedFrom) {
            // remove any matches based on SupplyType and count
            print("newSupplyCounts has: \(newSupplyCounts.count)")
            removeMatchingCountsFromNewSupplyCounts()
            print("now newSupplyCounts has: \(newSupplyCounts.count)")
            
            // send updated SupplyCounts to Firestore
            submitSupplyCounts(supplyCounts: newSupplyCounts) {}
            
            // create new list of SupplyCounts by merging supplyCounts and newSupplyCounts
            let allSupplyCounts = mergeSupplyCounts(originalSupplyCounts: supplyCounts, newSupplyCounts: newSupplyCounts)
            
            // create InventoryEntry struct and add to Firestore
            createInventoryEntry(supplyCounts: allSupplyCounts) {
                // call completion after entry is created
                completion()
            }
        // else type is .MoveTo or .Use (newSupplyCounts includes all supplyTypes)
        } else {
            // create new list of only SupplyCounts that reported used/moved
            let updates = newSupplyCounts.filter { $0.usedCount != 0 }
            
            // send updated SupplyCounts to Firestore
            submitSupplyCounts(supplyCounts: updates) { }
            
            // create InventoryEntry struct and add to Firestore
            createInventoryEntry(supplyCounts: newSupplyCounts) { 
                // call completion after batch update
                completion()
            }
        }
    }
}
