//
//  InventoryTypeManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/6/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct InventoryType: Codable, Hashable {
    let id: String
    let name: String
    let keyTypeId: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case keyTypeId = "key_type"
    }
}
class InventoryTypeManager {
    static let shared = InventoryTypeManager()
    private init() { }

    private var inventoryTypes: [InventoryType] = []

    // get the collection as CollectionReference
    private let inventoryTypesCollection: CollectionReference = Firestore.firestore().collection("inventory_types")
    
    // get Firestore document as DocumentReference
    private func inventoryTypeDocument(inventoryTypeId: String) -> DocumentReference {
        inventoryTypesCollection.document(inventoryTypeId)
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
    
    // get an inventory type from Firestore as inventorySite struct
    func getInventoryType(inventoryTypeId: String) async throws -> InventoryType {
        try await inventoryTypeDocument(inventoryTypeId: inventoryTypeId).getDocument(as: InventoryType.self)
    }
    
    // create a new inventory type in Firestore from struct
    func createInventoryType(inventoryType: InventoryType) async throws {
        // connect to Firestore and create a new document from codable struct
        try inventoryTypeDocument(inventoryTypeId: inventoryType.id).setData(from: inventoryType, merge: false)
    }
    
    // fetch inventory types collection onto local device
    private func getAllInventoryTypesQuery() -> Query {
        inventoryTypesCollection
    }
    
    // get inventory types sorted by Name
    private func getAllInventoryTypesSortedByNameQuery(descending: Bool) -> Query {
        inventoryTypesCollection
            .order(by: InventoryType.CodingKeys.name.rawValue, descending: descending)
    }
    
    // get inventory types by name
    func getAllInventoryTypes(descending: Bool?) async throws -> [InventoryType] {
        let query: Query = getAllInventoryTypesQuery()
        
//        // if given sort
//        if let descending {
//            // sort whole collection
//            query = getAllSitesSortedByNameQuery(descending: descending)
//        }
        print("trying to query inventory types collection, query: \(query)")
        return try await query
            .getDocuments(as: InventoryType.self) // query inventory_types collection
    }
    
    // get count of all sites
    // we can use this to determine if we need to use pagination
    func allInventoryTypesCount() async throws -> Int {
        try await inventoryTypesCollection.aggregateCount()
    }
}
