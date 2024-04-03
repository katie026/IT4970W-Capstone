//
//  InventoryManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/6/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct InventorySite: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String?
    let buildingId: String?
    let inventoryTypeIds: [String]?
    
    // create InventorySite manually
    init(
        id: String,
        name: String? = nil,
        buildingId: String? = nil,
        inventoryTypeIds: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.buildingId = buildingId
        self.inventoryTypeIds = inventoryTypeIds
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case buildingId = "building"
        case inventoryTypeIds = "inventory_types"
    }
    
    init(from decoder: Decoder) async throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.buildingId = try container.decodeIfPresent(String.self, forKey: .buildingId)
        self.inventoryTypeIds = try container.decodeIfPresent([String].self, forKey: .inventoryTypeIds)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.buildingId, forKey: .buildingId)
        try container.encodeIfPresent(self.inventoryTypeIds, forKey: .inventoryTypeIds)
    }
    
    static func == (lhs:InventorySite, rhs: InventorySite) -> Bool {
        // if two sites have the same ID, we're going to say they're equal to eachother
        return lhs.id == rhs.id
    }
}

final class InventorySitesManager {
    // create singleton of manager
    static let shared = InventorySitesManager()
    private init() { }
    
    // get the collection as CollectionReference
    private let inventorySitesCollection: CollectionReference = Firestore.firestore().collection("inventory_sites")
    
    // get Firestore document as DocumentReference
    private func inventorySiteDocument(inventorySiteId: String) -> DocumentReference {
        inventorySitesCollection.document(inventorySiteId)
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
    
    // get an inventory site from Firestore as inventorySite struct
    func getInventorySite(inventorySiteId: String) async throws -> InventorySite {
        try await inventorySiteDocument(inventorySiteId: inventorySiteId).getDocument(as: InventorySite.self)
    }
    
    // create a new inventory site in Firestore from struct
    func createInventorySite(inventorySite: InventorySite) async throws {
        // connect to Firestore and create a new document from codable struct
        try inventorySiteDocument(inventorySiteId: inventorySite.id).setData(from: inventorySite, merge: false)
    }
    
    // fetch site collection onto local device
    private func getAllInventorySitesQuery() -> Query {
        inventorySitesCollection
    }
    
    // get sites sorted by Name
    private func getAllInventorySitesSortedByNameQuery(descending: Bool) -> Query {
        inventorySitesCollection
            .order(by: InventorySite.CodingKeys.name.rawValue, descending: descending)
    }
    
    // get inventory sites by name
    func getAllInventorySites(descending: Bool?) async throws -> [InventorySite] {
        let query: Query = getAllInventorySitesQuery()
        
//        // if given sort
//        if let descending {
//            // sort whole collection
//            query = getAllSitesSortedByNameQuery(descending: descending)
//        }
        print("Querying all inventory sites.")
        return try await query
            .getDocuments(as: InventorySite.self) // query inventory_site collection
    }
    
    // get count of all sites
    // we can use this to determine if we need to use pagination
    func allInventorySitesCount() async throws -> Int {
        try await inventorySitesCollection.aggregateCount()
    }
}
