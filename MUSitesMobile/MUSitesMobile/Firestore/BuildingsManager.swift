//
//  BuildingsManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/19/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Address: Codable {
    let city: String?
    let country: String?
    let state: String?
    let street: String?
    let zipCode: String?
    
    enum CodingKeys: String, CodingKey {
        case city, country, state, street
        case zipCode = "zip_code" // Map zipCode to zip_code in Firestore
    }
}

struct Building: Identifiable, Codable, Equatable { // allow encoding and decoding
    let id: String
    let name: String?
    let address: Address?
    let coordinates: GeoPoint?
    let isLibrary: Bool?
    let isReshall: Bool?
    let siteGroupId: String?
    
    // create Building manually
    init(
        id: String,
        name: String? = nil,
        address: Address? = nil,
        coordinates: GeoPoint? = nil,
        isLibrary: Bool? = nil,
        isReshall: Bool? = nil,
        siteGroupId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.coordinates = coordinates
        self.isLibrary = isLibrary
        self.isReshall = isReshall
        self.siteGroupId = siteGroupId
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case address = "address"
        case coordinates = "coordinates"
        case isLibrary = "is_library"
        case isReshall = "is_reshall"
        case siteGroupId = "site_group"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.address = try container.decodeIfPresent(Address.self, forKey: .address)
        self.coordinates = try container.decodeIfPresent(GeoPoint.self, forKey: .coordinates)
        self.isLibrary = try container.decodeIfPresent(Bool.self, forKey: .isLibrary)
        self.isReshall = try container.decodeIfPresent(Bool.self, forKey: .isReshall)
        self.siteGroupId = try container.decodeIfPresent(String.self, forKey: .siteGroupId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.address, forKey: .address)
        try container.encodeIfPresent(self.coordinates, forKey: .coordinates)
        try container.encodeIfPresent(self.isLibrary, forKey: .isLibrary)
        try container.encodeIfPresent(self.isReshall, forKey: .isReshall)
        try container.encodeIfPresent(self.siteGroupId, forKey: .siteGroupId)
    }
    
    static func == (lhs:Building, rhs: Building) -> Bool {
        // if two buildings have the same ID, we're going to say they're equal to eachother
        return lhs.id == rhs.id
    }
}

final class BuildingsManager {    
    // create singleton of BuildingsManager
    static let shared = BuildingsManager()
    private init() { }
    
    private var Buildings: [Building] = []
    
    // get the 'buildings' collection as CollectionReference
    private let buildingsCollection: CollectionReference = Firestore.firestore().collection("buildings")
    
    // get building's Firestore document as DocumentReference
    private func buildingDocument(buildingId: String) -> DocumentReference {
        buildingsCollection.document(buildingId)
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
    
    // get a building from Firestore as Building struct
    func getBuilding(buildingId: String) async throws -> Building {
        try await buildingDocument(buildingId: buildingId).getDocument(as: Building.self)
    }
    
    //query for getting buildings with specific ids
    func getBuildingWithQuery(buildingId: String) async throws -> Building? {
        let query = buildingsCollection.whereField("id", isEqualTo: buildingId)
        
        let querySnapshot = try await query.getDocuments()
        
        if let document = querySnapshot.documents.first {
            return try document.data(as: Building.self)
        }
        else{
            return nil
        }
    }
    
    // create a new building in Firestore
    func createBuilding(building: Building) async throws {
        // connect to Firestore and create a new document from codable Building struct
        try buildingDocument(buildingId: building.id).setData(from: building, merge: false)
    }
    
    // fetch building collection onto local device
    private func getAllBuildingsQuery() -> Query {
        buildingsCollection
    }
    
    // get buildings sorted by Name
    private func getAllBuildingsSortedByNameQuery(descending: Bool) -> Query {
        buildingsCollection
            .order(by: Building.CodingKeys.name.rawValue, descending: descending)
    }
    
    // get buildings filtered by Group
    private func getAllBuildingsFilteredByGroupQuery(siteGroupId: String) -> Query {
        buildingsCollection
            .whereField(Building.CodingKeys.siteGroupId.rawValue, isEqualTo: siteGroupId)
    }
    
    // get buildings filtered by group & sorted name
    private func getAllBuildingsByGroupAndNameQuery(nameDescending: Bool, group: String) -> Query {
        buildingsCollection
            // filter by group
            .whereField(Building.CodingKeys.siteGroupId.rawValue, isEqualTo: group)
            // sort by name
            .order(by: Building.CodingKeys.siteGroupId.rawValue, descending: nameDescending)
    }
    
    // get buildings by Group and/or Name
    func getAllBuildings(descending: Bool?, group: String?) async throws -> [Building] {
        var query: Query = getAllBuildingsQuery()
        
        // if given a Group and nameSort
        if let descending, let group {
            // filter and sort collection
            query = getAllBuildingsByGroupAndNameQuery(nameDescending: descending, group: group)
        // if given sort
        } else if let descending {
            // sort whole collection
            query = getAllBuildingsSortedByNameQuery(descending: descending)
        // if given filter
        } else if let group {
            // filter whole collection
            query = getAllBuildingsFilteredByGroupQuery(siteGroupId: group)
        }
        
        return try await query
            .getDocuments(as: Building.self) // query buildings collection
    }
    
    // get count of all buildings
    // we can use this to determine if we need to use pagination
    func allBuildingsCount() async throws -> Int {
        try await buildingsCollection.aggregateCount()
    }
}
