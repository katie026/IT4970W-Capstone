//
//  KeySetManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/7/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct KeySet: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String?
    let nickname: String?
    let notes: String?
    let buildingId: String?
    let lastChecked: Date?
    let staticLocation: Bool?
    let userId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case nickname = "nickname"
        case notes = "notes"
        case buildingId = "building"
        case lastChecked = "last_checked"
        case staticLocation = "static_location"
        case userId = "user"
    }
    
    static func == (lhs:KeySet, rhs: KeySet) -> Bool {
        // if two key sets have the same ID, we're going to say they're equal to eachother
        return lhs.id == rhs.id
    }
}

class KeySetManager {
    static let shared = KeySetManager()
    private init() { }

    private var keySets: [KeySet] = []

    // get the collection as CollectionReference
    private let keySetsCollection: CollectionReference = Firestore.firestore().collection("key_sets")
    
    // get Firestore document as DocumentReference
    private func keySetDocument(keySetId: String) -> DocumentReference {
        keySetsCollection.document(keySetId)
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
    
    // get a key set from Firestore as keySet struct
    func getKeySet(keySetId: String) async throws -> KeySet {
        try await keySetDocument(keySetId: keySetId).getDocument(as: KeySet.self)
    }
    
    // Fetch a KeySet based on userId from Firestore
    func getKeySetForUser(userId: String) async throws -> KeySet? {
        let query = keySetsCollection.whereField(KeySet.CodingKeys.userId.rawValue, isEqualTo: userId)
        
        do {
            let querySnapshot = try await query.getDocuments()
            if let keySetDocument = querySnapshot.documents.first {
                return try keySetDocument.data(as: KeySet.self)
            } else {
                // KeySet not found for userId
                return nil
            }
        } catch {
            throw error
        }
    }
    
    // create a new key set in Firestore from struct
    func createKeySet(keySet: KeySet) async throws {
        // connect to Firestore and create a new document from codable struct
        try keySetDocument(keySetId: keySet.id).setData(from: keySet, merge: false)
    }
    
    // fetch key types collection onto local device
    private func getAllKeySetsQuery() -> Query {
        keySetsCollection
    }
    
    // get key types sorted by Name
    private func getAllKeySetsSortedByNameQuery(descending: Bool) -> Query {
        keySetsCollection
            .order(by: KeySet.CodingKeys.name.rawValue, descending: descending)
    }
    
    // get key sets by name
    func getAllKeySets(descending: Bool?) async throws -> [KeySet] {
        let query: Query = getAllKeySetsQuery()
        
//        // if given sort
//        if let descending {
//            // sort whole collection
//            query = getAllSitesSortedByNameQuery(descending: descending)
//        }
        print("trying to query key types collection, query: \(query)")
        return try await query
            .getDocuments(as: KeySet.self) // query key_types collection
    }
    
    // get count of all sites
    // we can use this to determine if we need to use pagination
    func allKeySetsCount() async throws -> Int {
        try await keySetsCollection.aggregateCount()
    }
}

