//
//  KeyTypeManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/6/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct KeyType: Codable {
    let id: String
    let name: String
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case notes = "notes"
    }
}

class KeyTypeManager {
    static let shared = KeyTypeManager()
    private init() { }

    private var keyTypes: [KeyType] = []

    // get the collection as CollectionReference
    private let keyTypesCollection: CollectionReference = Firestore.firestore().collection("key_types")
    
    // get Firestore document as DocumentReference
    private func keyTypeDocument(keyTypeId: String) -> DocumentReference {
        keyTypesCollection.document(keyTypeId)
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
    
    // get an key type from Firestore as keyType struct
    func getKeyType(keyTypeId: String) async throws -> KeyType {
        try await keyTypeDocument(keyTypeId: keyTypeId).getDocument(as: KeyType.self)
    }
    
    // create a new key type in Firestore from struct
    func createKeyType(keyType: KeyType) async throws {
        // connect to Firestore and create a new document from codable struct
        try keyTypeDocument(keyTypeId: keyType.id).setData(from: keyType, merge: false)
    }
    
    // fetch key types collection onto local device
    private func getAllKeyTypesQuery() -> Query {
        keyTypesCollection
    }
    
    // get key types sorted by Name
    private func getAllKeyTypesSortedByNameQuery(descending: Bool) -> Query {
        keyTypesCollection
            .order(by: KeyType.CodingKeys.name.rawValue, descending: descending)
    }
    
    // get key types by name
    func getAllKeyTypes(descending: Bool?) async throws -> [KeyType] {
        let query: Query = getAllKeyTypesQuery()
        
//        // if given sort
//        if let descending {
//            // sort whole collection
//            query = getAllSitesSortedByNameQuery(descending: descending)
//        }
        print("trying to query key types collection, query: \(query)")
        return try await query
            .getDocuments(as: KeyType.self) // query key_types collection
    }
    
    // get count of all sites
    // we can use this to determine if we need to use pagination
    func allKeyTypesCount() async throws -> Int {
        try await keyTypesCollection.aggregateCount()
    }
}

