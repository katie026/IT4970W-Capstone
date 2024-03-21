//
//  InventorySubmissionViewManager.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/17/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SupplyCount: Codable {
    let id: String
    let inventorySiteId: String?
    let supplyType: String?
    let countMin: Int?
    let count: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case inventorySiteId = "inventory_site"
        case supplyType = "supply_type"
        case countMin = "minimum"
        case count = "count"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.inventorySiteId = try container.decodeIfPresent(String.self, forKey: .inventorySiteId)
        self.supplyType = try container.decodeIfPresent(String.self, forKey: .supplyType)
        self.countMin = try container.decodeIfPresent(Int.self, forKey: .countMin)
        self.count = try container.decodeIfPresent(Int.self, forKey: .count)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.inventorySiteId, forKey: .inventorySiteId)
        try container.encodeIfPresent(self.supplyType, forKey: .supplyType)
        try container.encodeIfPresent(self.countMin, forKey: .countMin)
        try container.encodeIfPresent(self.count, forKey: .count)
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
    
    // get an key type from Firestore as SupplyCount struct
    func getSupplyCount(supplyCountId: String) async throws -> SupplyCount {
        try await supplyCountDocument(supplyCountId: supplyCountId).getDocument(as: SupplyCount.self)
    }
    
    // create a new key type in Firestore from struct
    func createSupplyCount(supplyCount: SupplyCount) async throws {
        // connect to Firestore and create a new document from codable struct
        try supplyCountDocument(supplyCountId: supplyCount.id).setData(from: supplyCount, merge: false)
    }
    
    // fetch key types collection onto local device
    private func getAllSupplyCountsQuery() -> Query {
        supplyCountsCollection
    }
    
    // get key types sorted by Inventory Site Name
    private func getAllSupplyCountsSortedBySiteQuery(descending: Bool) -> Query {
        supplyCountsCollection
            .order(by: SupplyCount.CodingKeys.inventorySiteId.rawValue, descending: descending)
    }
    
    // get key types by name
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
}

