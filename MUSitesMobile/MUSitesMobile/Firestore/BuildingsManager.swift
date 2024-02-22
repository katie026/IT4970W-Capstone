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

struct Building: Identifiable, Codable { // allow encoding and decoding
    let id: String
    let name: String?
    let address: Address?
    let coordinates: GeoPoint?
    let isLibrary: Bool?
    let isReshall: Bool?
    let siteGroup: String?
    
    // create Building manually
    init(
        id: String,
        name: String? = nil,
        address: Address? = nil,
        coordinates: GeoPoint? = nil,
        isLibrary: Bool? = nil,
        isReshall: Bool? = nil,
        siteGroup: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.coordinates = coordinates
        self.isLibrary = isLibrary
        self.isReshall = isReshall
        self.siteGroup = siteGroup
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case address = "address"
        case coordinates = "coordinates"
        case isLibrary = "is_library"
        case isReshall = "is_reshall"
        case siteGroup = "site_group"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.address = try container.decodeIfPresent(Address.self, forKey: .address)
        self.coordinates = try container.decodeIfPresent(GeoPoint.self, forKey: .coordinates)
        self.isLibrary = try container.decodeIfPresent(Bool.self, forKey: .isLibrary)
        self.isReshall = try container.decodeIfPresent(Bool.self, forKey: .isReshall)
        self.siteGroup = try container.decodeIfPresent(String.self, forKey: .siteGroup)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.address, forKey: .address)
        try container.encodeIfPresent(self.coordinates, forKey: .coordinates)
        try container.encodeIfPresent(self.isLibrary, forKey: .isLibrary)
        try container.encodeIfPresent(self.isReshall, forKey: .isReshall)
        try container.encodeIfPresent(self.siteGroup, forKey: .siteGroup)
    }
}

final class BuildingsManager {    
    // create singleton of BuildingsManager
    static let shared = BuildingsManager()
    private init() { }
    
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
    
    // create a new building in Firestore
    func createBuilding(building: Building) async throws {
        // connect to Firestore and create a new document from codable Building struct
        try buildingDocument(buildingId: building.id).setData(from: building, merge: false)
    }
    
    // fetch building collection onto local device
    func getAllBuildings() async throws -> [Building] {
        try await buildingsCollection.getDocuments(as: Building.self)
    }
    
    // get buildings by Group & sorted
    func getAllBuildingsByGroup(descending: Bool?, filter: String?) async throws -> [Building] {
        // if given a sort and filter
        if let descending, let filter {
            return try await getAllBuildingsByGroupAndFilter(descending: descending, filter: filter)
        // if given sort
        } else if let descending {
            return try await getAllBuildingsSortedByGroup(descending: descending)
        // if given filter
        } else if let filter {
            return try await getAllBuildingsFilteredByGroup(siteGroup: filter)
        }
        
        // else return all
        return try await getAllBuildings()
    }
    
    // get buildings by Group & sorted
    private func getAllBuildingsByGroupAndFilter(descending: Bool, filter: String) async throws -> [Building] {
        try await buildingsCollection
            // filter by group
            .whereField(Building.CodingKeys.siteGroup.rawValue, isEqualTo: filter)
            // sort by group
            .order(by: Building.CodingKeys.siteGroup.rawValue, descending: descending)
            .getDocuments(as: Building.self)
    }
    
    // get buildings sorted by Name
    func getAllBuildingsSortedByName(descending: Bool) async throws -> [Building] {
        try await buildingsCollection.order(by: Building.CodingKeys.name.rawValue, descending: descending).getDocuments(as: Building.self)
    }
    
    // get buildings sorted by Group
    private func getAllBuildingsSortedByGroup(descending: Bool) async throws -> [Building] {
        try await buildingsCollection.order(by: Building.CodingKeys.siteGroup.rawValue, descending: descending).getDocuments(as: Building.self) // order by: document fields
    }
    
    // get buildings filtered by Group
    private func getAllBuildingsFilteredByGroup(siteGroup: String) async throws -> [Building] {
        try await buildingsCollection.whereField(Building.CodingKeys.siteGroup.rawValue, isEqualTo: siteGroup).getDocuments(as: Building.self)
    }
    
    // get buildings filtered by isResHall
    func getAllBuildingsFilteredByIsResHall() async throws -> [Building] {
        return try await buildingsCollection.whereField(Building.CodingKeys.isReshall.rawValue, isEqualTo: true).getDocuments(as: Building.self)
    }
    
    // get buildings filtered by isLibrary
    func getAllBuildingsFilteredByIsLibrary() async throws -> [Building] {
        return try await buildingsCollection.whereField(Building.CodingKeys.isLibrary.rawValue, isEqualTo: true).getDocuments(as: Building.self)
    }
}

extension Query {
    // using generics
    // given any Decodable type, return an array of that type
    func getDocuments<T> (as type: T.Type) async throws -> [T] where T: Decodable {
        // we can get a collection of documents, BUT they will count against our fetching quota, so if it is a large collection, we should query first
        
        // fetch a snapshot of the collection from Firestore
        let snapshot = try await self.getDocuments()
        
        // map the documents in snapshot as an array of type T and return the array
        return try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
//        // using empty array and for loop
//        // create an array to hold Buildings
//        var itemArray: [T] = []
//        
//        // decode each building into a Building struct
//        for document in snapshot.documents {
//            // try to decode
//            let item = try document.data(as: T.self)
//            // add to Building array
//            itemArray.append(item)
//        }
//        return itemArray
    }
}
