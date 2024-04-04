//
//  InventoryEntriesManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/22/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum InventoryEntryType: String, Codable {
    case NA
    case Check
    case Fix
    case Delivery
    case Use
    case MoveTo
    case MovedFrom
}

struct InventoryEntry: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let inventorySiteId: String?
    let timestamp: Date?
    let type: InventoryEntryType?
    let userId: String?
    // supplies
    let colorTabloid: Int?
    let bwTabloid: Int?
    let threeMSpray: Int?
    let bwPaper: Int?
    let colorPaper: Int?
    let wipes: Int?
    let paperTowel: Int?
    
    // create InventoryEntry manually
    init(
        id: String,
        inventorySiteId: String? = nil,
        timestamp: Date? = nil,
        type: InventoryEntryType? = nil,
        userId: String? = nil,
        colorTabloid: Int? = nil,
        bwTabloid: Int? = nil,
        threeMSpray: Int? = nil,
        bwPaper: Int? = nil,
        colorPaper: Int? = nil,
        wipes: Int? = nil,
        paperTowel: Int? = nil
    ) {
        self.id = id
        self.inventorySiteId = inventorySiteId
        self.timestamp = timestamp
        self.type = type
        self.userId = userId
        self.colorTabloid = colorTabloid
        self.bwTabloid = bwTabloid
        self.threeMSpray = threeMSpray
        self.bwPaper = bwPaper
        self.colorPaper = colorPaper
        self.wipes = wipes
        self.paperTowel = paperTowel
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case inventorySiteId = "inventory_site"
        case timestamp = "timestamp"
        case type = "type"
        case userId = "user"
        case colorTabloid = "5dbQL6Jmc3ezlsqR75Pu"
        case bwTabloid = "B17QKJXEM3oPLaoreQWn"
        case threeMSpray = "SWHMBwzJaR3EggqgWNEk"
        case bwPaper = "dpj0LV4bBdw8wRVle7aD"
        case colorPaper = "rGTzAyr1CXN2NV0sapK1"
        case wipes = "w4V5uYVeF48AvfcgAFN1"
        case paperTowel = "yOPDkKB4wVEB1dTK9fXy"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.inventorySiteId = try container.decodeIfPresent(String.self, forKey: .inventorySiteId)
        self.timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp)
        
//        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        // Decode the type as a String
        let typeString = try container.decodeIfPresent(String.self, forKey: .type)
        // Convert the typeString to InventoryEntryType enum
        self.type = InventoryEntryType(rawValue: typeString ?? "NA")
        
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
        self.colorTabloid = try container.decodeIfPresent(Int.self, forKey: .colorTabloid)
        self.bwTabloid = try container.decodeIfPresent(Int.self, forKey: .bwTabloid)
        self.threeMSpray = try container.decodeIfPresent(Int.self, forKey: .threeMSpray)
        self.bwPaper = try container.decodeIfPresent(Int.self, forKey: .bwPaper)
        self.colorPaper = try container.decodeIfPresent(Int.self, forKey: .colorPaper)
        self.wipes = try container.decodeIfPresent(Int.self, forKey: .wipes)
        self.paperTowel = try container.decodeIfPresent(Int.self, forKey: .paperTowel)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.inventorySiteId, forKey: .inventorySiteId)
        try container.encodeIfPresent(self.timestamp, forKey: .timestamp)
        
//        try container.encodeIfPresent(self.type, forKey: .type)
        // Encode type as rawValue
        try container.encodeIfPresent(self.type?.rawValue, forKey: .type)
        
        try container.encodeIfPresent(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.colorTabloid, forKey: .colorTabloid)
        try container.encodeIfPresent(self.bwTabloid, forKey: .bwTabloid)
        try container.encodeIfPresent(self.threeMSpray, forKey: .threeMSpray)
        try container.encodeIfPresent(self.bwPaper, forKey: .bwPaper)
        try container.encodeIfPresent(self.colorPaper, forKey: .colorPaper)
        try container.encodeIfPresent(self.wipes, forKey: .wipes)
        try container.encodeIfPresent(self.paperTowel, forKey: .paperTowel)
    }
    
    static func == (lhs:InventoryEntry, rhs: InventoryEntry) -> Bool {
        // if two entries have the same ID, we're going to say they're equal to eachother
        return lhs.id == rhs.id
    }
}

final class InventoryEntriesManager {
    // create singleton of manager
    static let shared = InventoryEntriesManager()
    private init() { }
    
    // get the collection as CollectionReference
    private let inventoryEntriesCollection: CollectionReference = Firestore.firestore().collection("inventory_entries")
    
    // get Firestore document as DocumentReference
    private func inventoryEntryDocument(inventoryEntryId: String) -> DocumentReference {
        inventoryEntriesCollection.document(inventoryEntryId)
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
    
    // get an inventory entry from Firestore as inventoryEntry struct
    func getInventoryEntry(inventoryEntryId: String) async throws -> InventoryEntry {
        try await inventoryEntryDocument(inventoryEntryId: inventoryEntryId).getDocument(as: InventoryEntry.self)
    }
    
    // create a new inventory entry in Firestore from struct
    func createInventoryEntry(inventoryEntry: InventoryEntry) async throws {
        // connect to Firestore and create a new document from codable struct
        try inventoryEntryDocument(inventoryEntryId: inventoryEntry.id).setData(from: inventoryEntry, merge: false)
    }
    
    // create new inventory entry document in Firestore, return id
    func getNewInventoryEntryId() async throws -> String {
        // create auto-generated document in collection
        let document = inventoryEntriesCollection.document()
        // get document id
        return document.documentID
    }
    
    // fetch entry collection onto local device
    private func getAllInventoryEntriesQuery() -> Query {
        inventoryEntriesCollection
    }
    
    // get entries sorted by timestamp
    private func getAllInventoryEntriesSortedByNameQuery(descending: Bool) -> Query {
        inventoryEntriesCollection
            .order(by: InventoryEntry.CodingKeys.timestamp.rawValue, descending: descending)
    }
    
    // get inventory entries by __
    func getAllInventoryEntries(descending: Bool?) async throws -> [InventoryEntry] {
        let query: Query = getAllInventoryEntriesQuery()
        
//        // if given sort
//        if let descending {
//            // sort whole collection
//            query = getAllSitesSortedByNameQuery(descending: descending)
//        }
        print("Querying all inventory entries.")
        return try await query
            .getDocuments(as: InventoryEntry.self) // query inventory_entries collection
    }
    
    // get count of all entries
    // we can use this to determine if we need to use pagination
    func allInventoryEntriesCount() async throws -> Int {
        try await inventoryEntriesCollection.aggregateCount()
    }
}
