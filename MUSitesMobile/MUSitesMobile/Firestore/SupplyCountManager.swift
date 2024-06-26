//
//  SupplyCountManager.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/17/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol Copyable {
    func copy() -> Self
}

struct SupplyCount: Identifiable, Codable, Copyable {
    // Properties
    var id: String
    // vars because they may need to be changed
    var inventorySiteId: String?
    var supplyTypeId: String?
    var countMin: Int?
    var level: Int?
    var count: Int?
    // will not be coded
    var usedCount: Int = 0
    
    // create SupplyCount manually
    init(
        id: String,
        inventorySiteId: String? = nil,
        supplyTypeId: String? = nil,
        countMin: Int? = nil,
        count: Int? = nil,
        level: Int? = nil
    ) {
        self.id = id
        self.inventorySiteId = inventorySiteId
        self.supplyTypeId = supplyTypeId
        self.countMin = countMin
        self.count = count
        self.level = level
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case inventorySiteId = "inventory_site"
        case supplyTypeId = "supply_type"
        case countMin = "minimum"
        case count = "count"
        case level = "level"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.inventorySiteId = try container.decodeIfPresent(String.self, forKey: .inventorySiteId)
        self.supplyTypeId = try container.decodeIfPresent(String.self, forKey: .supplyTypeId)
        self.countMin = try container.decodeIfPresent(Int.self, forKey: .countMin)
        self.count = try container.decodeIfPresent(Int.self, forKey: .count)
        self.level = try container.decodeIfPresent(Int.self, forKey: .level)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.inventorySiteId, forKey: .inventorySiteId)
        try container.encodeIfPresent(self.supplyTypeId, forKey: .supplyTypeId)
        try container.encodeIfPresent(self.countMin, forKey: .countMin)
        try container.encodeIfPresent(self.count, forKey: .count)
        try container.encodeIfPresent(self.level, forKey: .level)
    }
    
    // Copyable Protocal
    func copy() -> SupplyCount {
        return SupplyCount(
            id: self.id,
            inventorySiteId: self.inventorySiteId,
            supplyTypeId: self.supplyTypeId,
            countMin: self.countMin,
            count: self.count,
            level: self.level
        )
    }
}

class SupplyCountManager {
    static let shared = SupplyCountManager()
    private init() { }
    
    private var supplyCounts: [SupplyCount] = []
    
    // get the collection as CollectionReference
    private let supplyCountsCollection: CollectionReference = Firestore.firestore().collection("supplies")
    
    // get Firestore document as DocumentReference
    private func supplyCountDocument(supplyCountId: String) -> DocumentReference {
        supplyCountsCollection.document(supplyCountId)
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
    
    // get an supply count from Firestore as SupplyCount struct
    func getSupplyCount(supplyCountId: String) async throws -> SupplyCount {
        try await supplyCountDocument(supplyCountId: supplyCountId).getDocument(as: SupplyCount.self)
    }
    
    // create new supply count document in Firestore, return id
    func getNewSupplyCountId() async throws -> String {
        // create auto-generated document in collection
        let document = supplyCountsCollection.document()
        // get document id
        return document.documentID
    }
    
    // create a new supply count in Firestore from struct
    func createSupplyCount(supplyCount: SupplyCount) async throws {
        // connect to Firestore and create a new document from codable struct
        try supplyCountDocument(supplyCountId: supplyCount.id).setData(from: supplyCount, merge: false)
    }
    
    // fetch supply counts collection onto local device
    private func getAllSupplyCountsQuery() -> Query {
        supplyCountsCollection
    }
    
    // get supply counts sorted by Inventory Site Name
    private func getAllSupplyCountsSortedBySiteQuery(descending: Bool) -> Query {
        supplyCountsCollection
            .order(by: SupplyCount.CodingKeys.inventorySiteId.rawValue, descending: descending)
    }
    
    // get supply counts filtered by Inventory Site Name
    func getAllSupplyCountsBySite(siteId: String) async throws -> [SupplyCount] {
        return try await supplyCountsCollection
        // filter by group
            .whereField(SupplyCount.CodingKeys.inventorySiteId.rawValue, isEqualTo: siteId)
            .getDocuments(as: SupplyCount.self)
    }
    
    // get supply counts by site
    func getAllSupplyCounts(descending: Bool?) async throws -> [SupplyCount] {
        let query: Query = getAllSupplyCountsQuery()
        
        //        // if given sort
        //        if let descending {
        //            // sort whole collection
        //            query = getAllSitesSortedByNameQuery(descending: descending)
        //        }
        print("trying to query supplies collection, query: \(query)")
        return try await query
            .getDocuments(as: SupplyCount.self) // query supplies collection
    }
    
    // get count of all supplies
    // we can use this to determine if we need to use pagination
    func allSupplyCountsCount() async throws -> Int {
        try await supplyCountsCollection.aggregateCount()
    }
    
    // get supply type name from supplyTypeId
    func getSupplyTypeName(supplyTypeId: String) async -> String? {
        do {
            // Use 'try await' to call the asynchronous function within the async context
            let supplyType = try await SupplyTypeManager.shared.getSupplyType(supplyTypeId: supplyTypeId)
            return supplyType.name
        } catch {
            // Handle errors if any
            print("Error fetching supply type name: \(error)")
            return nil
        }
    }
    
    func updateSupplyCounts(_ supplyCounts: [SupplyCount]) async throws {
        // Create a new batched write operation
        let batch = Firestore.firestore().batch()
        
        // Iterate over the supplyCounts array and update each document in the batch
        for supplyCount in supplyCounts {
            // Get the reference to the document
            let documentRef = supplyCountDocument(supplyCountId: supplyCount.id)
            
            // Encode the updated supplyCount object
            guard let data = try? encoder.encode(supplyCount) else {
                // Handle encoding error
                throw SupplyCountManagerError.encodingError
            }
            
            // Set the data for the document in the batch
            batch.setData(data, forDocument: documentRef)
        }
        
        // Commit the batched write operation
        try await batch.commit()
    }
    
}

// Errors
enum SupplyCountManagerError: Error {
    case noSupplyTypeId
    case encodingError
}
