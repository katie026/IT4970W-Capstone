//
//  SupplyTypeManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SupplyType: Codable, Hashable {
    let id: String
    let name: String
    let notes: String?
    let collectLevel: Bool?

    init(id: String, name: String, notes: String?, collectLevel: Bool?) {
        self.id = id
        self.name = name
        self.notes = notes
        self.collectLevel = collectLevel
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case notes = "notes"
        case collectLevel = "collect_level"
    }
    
    

}

class SupplyTypeManager {
    static let shared = SupplyTypeManager()
    private init() { }

    @Published var supplyTypes: [SupplyType] = []

    // get the collection as CollectionReference
    private let supplyTypesCollection: CollectionReference = Firestore.firestore().collection("supply_types")

    // get Firestore document as DocumentReference
    private func supplyTypeDocument(supplyTypeId: String) -> DocumentReference {
        supplyTypesCollection.document(supplyTypeId)
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

    // get an supply type from Firestore as supplyType struct
    func getSupplyType(supplyTypeId: String) async throws -> SupplyType {
        try await supplyTypeDocument(supplyTypeId: supplyTypeId).getDocument(as: SupplyType.self)
    }

    // create a new supply type in Firestore from struct
    func createSupplyType(supplyType: SupplyType) async throws {
        // connect to Firestore and create a new document from codable struct
        try supplyTypeDocument(supplyTypeId: supplyType.id).setData(from: supplyType, merge: false)
    }

    // fetch supply types collection onto local device
    private func getAllSupplyTypesQuery() -> Query {
        supplyTypesCollection
    }

    // get supply types sorted by Name
    private func getAllSupplyTypesSortedByNameQuery(descending: Bool) -> Query {
        supplyTypesCollection
            .order(by: SupplyType.CodingKeys.name.rawValue, descending: descending)
    }

    // get all supply types
    func getAllSupplyTypes(descending: Bool?) async throws -> [SupplyType] {
        var query = getAllSupplyTypesQuery()

        // if given sort
        if let descending {
            // sort whole collection
            query = getAllSupplyTypesSortedByNameQuery(descending: descending)
        }
        return try await query
            .getDocuments(as: SupplyType.self) // query key_types collection
    }

    // get count of all sites
    // we can use this to determine if we need to use pagination
    func allSupplyTypesCount() async throws -> Int {
        try await supplyTypesCollection.aggregateCount()
    }
    
    func fetchSupplyTypes() {
        Task {
            do {
                supplyTypes = try await getAllSupplyTypes(descending: false)
            } catch {
                print("Error fetching supply types: \(error)")
            }
        }
    }
}
