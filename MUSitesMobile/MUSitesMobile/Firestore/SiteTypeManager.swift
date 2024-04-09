//
//  SiteTypeManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/8/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SiteType: Codable, Identifiable {
    let id: String
    let name: String
    
    init(id: String, name: String, notes: String?) {
        self.id = id
        self.name = name
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
}

class SiteTypeManager {
    static let shared = SiteTypeManager()
    private init() { }

    private var siteTypes: [SiteType] = []

    // get the collection as CollectionReference
    private let siteTypesCollection: CollectionReference = Firestore.firestore().collection("computing_site_types")
    
    // get Firestore document as DocumentReference
    private func siteTypeDocument(siteTypeId: String) -> DocumentReference {
        siteTypesCollection.document(siteTypeId)
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
    
    // get an site type from Firestore as siteType struct
    func getSiteType(siteTypeId: String) async throws -> SiteType {
        try await siteTypeDocument(siteTypeId: siteTypeId).getDocument(as: SiteType.self)
    }
    
    // create a new site type in Firestore from struct
    func createSiteType(siteType: SiteType) async throws {
        // connect to Firestore and create a new document from codable struct
        try siteTypeDocument(siteTypeId: siteType.id).setData(from: siteType, merge: false)
    }
    
    // fetch site types collection onto local device
    private func getAllSiteTypesQuery() -> Query {
        siteTypesCollection
    }
    
    // get site types sorted by Name
    private func getAllSiteTypesSortedByNameQuery(descending: Bool) -> Query {
        siteTypesCollection
            .order(by: SiteType.CodingKeys.name.rawValue, descending: descending)
    }
    
    // get site types by name
    func getAllSiteTypes(descending: Bool?) async throws -> [SiteType] {
        var query = getAllSiteTypesQuery()
        
        // if given sort
        if let descending {
            // sort whole collection
            query = getAllSiteTypesSortedByNameQuery(descending: descending)
        }
        print("Trying to query site types collection.")
        return try await query
            .getDocuments(as: SiteType.self) // query site_types collection
    }
    
    // get count of all sites
    // we can use this to determine if we need to use pagination
    func allSiteTypesCount() async throws -> Int {
        try await siteTypesCollection.aggregateCount()
    }
}
