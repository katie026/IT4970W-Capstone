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
    let comments: String?
    
    // create InventoryEntry manually
    init(
        id: String,
        inventorySiteId: String? = nil,
        timestamp: Date? = nil,
        type: InventoryEntryType? = nil,
        userId: String? = nil,
        comments: String? = nil
    ) {
        self.id = id
        self.inventorySiteId = inventorySiteId
        self.timestamp = timestamp
        self.type = type
        self.userId = userId
        self.comments = comments
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case inventorySiteId = "inventory_site"
        case timestamp = "timestamp"
        case type = "type"
        case userId = "user"
        case comments = "comments"
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
        self.comments = try container.decodeIfPresent(String.self, forKey: .comments)
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
        try container.encodeIfPresent(self.comments, forKey: .comments)
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
    
    // get entries sorted by date
    private func getAllInventoryEntriesSortedByDateQuery(descending: Bool) -> Query {
        inventoryEntriesCollection
            .order(by: InventoryEntry.CodingKeys.timestamp.rawValue, descending: descending)
    }
    
    // get entries between two dates
    private func getInventoryEntriesBetweenDatesQuery(startDate: Date, endDate: Date) -> Query {
        inventoryEntriesCollection
            .whereField(InventoryEntry.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(InventoryEntry.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
    }
    
    // get entries between two dates & sorted by date
    private func getInventoryEntriesSortedBetweenDatesQuery(descending: Bool, startDate: Date, endDate: Date) -> Query {
        inventoryEntriesCollection
            // filter for dates
            .whereField(InventoryEntry.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(InventoryEntry.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
            // order by dates
            .order(by: InventoryEntry.CodingKeys.timestamp.rawValue, descending: descending)
    }
    
    // get inventory entries by __
    func getAllInventoryEntries(descending: Bool?, startDate: Date?, endDate: Date?) async throws -> [InventoryEntry] {
        // start with basic query to get whole collection
        var query: Query = getAllInventoryEntriesQuery()
        
        // if given sort & dates
        if let descending, let startDate, let endDate {
            query = getInventoryEntriesSortedBetweenDatesQuery(descending: descending, startDate: startDate, endDate: endDate)
        // if given only dates
        } else if let startDate, let endDate {
            query = getInventoryEntriesBetweenDatesQuery(startDate: startDate, endDate: endDate)
        // if given only dates
        } else if let descending {
            // replace query to sort whole collection first
            query = getAllInventoryEntriesSortedByDateQuery(descending: descending)
        }
        
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
