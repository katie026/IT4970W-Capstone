//
//  SupplyEntriesManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/4/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SupplyEntry: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let inventoryEntryId: String?
    let supplyTypeId: String?
    let count: Int?
    let level: Int?
    let used: Int?
    
    // create SupplyEntry manually
    init(
        id: String,
        inventoryEntryId: String? = nil,
        supplyTypeId: String? = nil,
        count: Int? = nil,
        level: Int? = nil,
        used: Int? = nil
    ) {
        self.id = id
        self.inventoryEntryId = inventoryEntryId
        self.supplyTypeId = supplyTypeId
        self.count = count
        self.level = level
        self.used = used
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case inventoryEntryId = "inventory_entry"
        case supplyTypeId = "supply_type"
        case count = "count"
        case level = "level"
        case used = "used"
    }
    
    static func == (lhs:SupplyEntry, rhs: SupplyEntry) -> Bool {
        // if two entries have the same ID, we're going to say they're equal to eachother
        return lhs.id == rhs.id
    }
}

final class SupplyEntriesManager {
    // create singleton of manager
    static let shared = SupplyEntriesManager()
    private init() { }
    
    // get the collection as CollectionReference
    private let supplyEntriesCollection: CollectionReference = Firestore.firestore().collection("supply_entries")
    
    // get Firestore document as DocumentReference
    private func supplyEntryDocument(supplyEntryId: String) -> DocumentReference {
        supplyEntriesCollection.document(supplyEntryId)
    }
    
    // create Firestore encoder
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    // create Firestore decoder
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    // get an supply entry from Firestore as supplyEntry struct
    func getSupplyEntry(supplyEntryId: String) async throws -> SupplyEntry {
        try await supplyEntryDocument(supplyEntryId: supplyEntryId).getDocument(as: SupplyEntry.self)
    }
    
    // create a new supply entry in Firestore from struct
    func createSupplyEntry(supplyEntry: SupplyEntry) async throws {
        // connect to Firestore and create a new document from codable struct
        try supplyEntryDocument(supplyEntryId: supplyEntry.id).setData(from: supplyEntry, merge: false)
    }
    
    // create new supply entry document in Firestore, return id
    func getNewSupplyEntryId() async throws -> String {
        // create auto-generated document in collection
        let document = supplyEntriesCollection.document()
        // get document id
        return document.documentID
    }
    
    // fetch entry collection onto local device
    private func getAllSupplyEntriesQuery() -> Query {
        supplyEntriesCollection
    }
    
    // get entries sorted by inventoryEntry
    private func getAllSupplyEntriesSortedByInventoryEntryIdQuery(descending: Bool) -> Query {
        supplyEntriesCollection
            .order(by: SupplyEntry.CodingKeys.inventoryEntryId.rawValue, descending: descending)
    }
    
    // get supply entries filtered by inventory entry id
    func getAllSupplyEntriesByInventoryEntry(inventoryEntryId: String) async throws -> [SupplyEntry] {
        return try await supplyEntriesCollection
        // filter by group
            .whereField(SupplyEntry.CodingKeys.inventoryEntryId.rawValue, isEqualTo: inventoryEntryId)
            .getDocuments(as: SupplyEntry.self)
    }
    
    // get supply entries by __
    func getAllSupplyEntries(descending: Bool?) async throws -> [SupplyEntry] {
        let query: Query = getAllSupplyEntriesQuery()
        
//        // if given sort
//        if let descending {
//            // sort whole collection
//            query = getAllSitesSortedByNameQuery(descending: descending)
//        }
        print("Querying all supply entries.")
        return try await query
            .getDocuments(as: SupplyEntry.self) // query supply_entries collection
    }
    
    // get count of all entries
    // we can use this to determine if we need to use pagination
    func allSupplyEntriesCount() async throws -> Int {
        try await supplyEntriesCollection.aggregateCount()
    }
}
