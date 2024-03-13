//
//  KeyManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Key: Identifiable, Codable, Equatable {
    let id: String
    let keyCode: String?
    let keySet: String?
    let keyType: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case keyCode = "key_code"
        case keySet = "key_set"
        case keyType = "key_type"
    }
    
    static func == (lhs:Key, rhs: Key) -> Bool {
        // if two keys have the same ID, we're going to say they're equal to eachother
        return lhs.id == rhs.id
    }
}

class KeyManager {
    static let shared = KeyManager()
    private init() { }

    private var keys: [Key] = []

    // get the collection as CollectionReference
    private let keysCollection: CollectionReference = Firestore.firestore().collection("keys")
    
    // get Firestore document as DocumentReference
    private func keyDocument(keyId: String) -> DocumentReference {
        keysCollection.document(keyId)
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
    
    // get a key from Firestore as key struct
    func getKey(keyId: String) async throws -> Key {
//        print("trying to decode key: \(keyId)")
        try await keyDocument(keyId: keyId).getDocument(as: Key.self)
    }
    
    // create a new key in Firestore from struct
    func createKey(key: Key) async throws {
        // connect to Firestore and create a new document from codable struct
        try keyDocument(keyId: key.id).setData(from: key, merge: false)
    }
    
    // fetch keys collection onto local device
    private func getAllKeysQuery() -> Query {
        keysCollection
    }
    
    // get all keys in a key set
    func getKeysForKeySet(keySetId: String) async throws -> [Key] {
        let query = keysCollection.whereField(Key.CodingKeys.keySet.rawValue, isEqualTo: keySetId)
        
        do {
            let querySnapshot = try await query.getDocuments()
            let keys: [Key] = try querySnapshot.documents.compactMap {
                try $0.data(as: Key.self)
            }
            return keys
        } catch {
            throw error
        }
    }
    
    // get keys sorted by keyCode
    private func getAllKeysSortedByCodeQuery(descending: Bool) -> Query {
        keysCollection
            .order(by: Key.CodingKeys.keyCode.rawValue, descending: descending)
    }
    
    // get key sets by keyCode
    func getAllKeys(descending: Bool?) async throws -> [Key] {
        let query: Query = getAllKeysQuery()
        
//        // if given sort
//        if let descending {
//            // sort whole collection
//            query = getAllSitesSortedByNameQuery(descending: descending)
//        }
        print("trying to query key types collection, query: \(query)")
        return try await query
            .getDocuments(as: Key.self) // query key_types collection
    }
    
    // get count of all keys
    // we can use this to determine if we need to use pagination
    func allKeysCount() async throws -> Int {
        try await keysCollection.aggregateCount()
    }
}


