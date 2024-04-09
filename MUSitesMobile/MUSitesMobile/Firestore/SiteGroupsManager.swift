//
//  SiteGroupsManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/8/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SiteGroup: Codable, Identifiable {
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

class SiteGroupManager {
    static let shared = SiteGroupManager()
    private init() { }

    private var siteGroups: [SiteGroup] = []

    // get the collection as CollectionReference
    private let siteGroupsCollection: CollectionReference = Firestore.firestore().collection("site_groups")
    
    // get Firestore document as DocumentReference
    private func siteGroupDocument(siteGroupId: String) -> DocumentReference {
        siteGroupsCollection.document(siteGroupId)
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
    
    // get an site group from Firestore as siteGroup struct
    func getSiteGroup(siteGroupId: String) async throws -> SiteGroup {
        try await siteGroupDocument(siteGroupId: siteGroupId).getDocument(as: SiteGroup.self)
    }
    
    // create a new site group in Firestore from struct
    func createSiteGroup(siteGroup: SiteGroup) async throws {
        // connect to Firestore and create a new document from codable struct
        try siteGroupDocument(siteGroupId: siteGroup.id).setData(from: siteGroup, merge: false)
    }
    
    // fetch site groups collection onto local device
    private func getAllSiteGroupsQuery() -> Query {
        siteGroupsCollection
    }
    
    // get site groups sorted by Name
    private func getAllSiteGroupsSortedByNameQuery(descending: Bool) -> Query {
        siteGroupsCollection
            .order(by: SiteGroup.CodingKeys.name.rawValue, descending: descending)
    }
    
    // get site groups by name
    func getAllSiteGroups(descending: Bool?) async throws -> [SiteGroup] {
        var query = getAllSiteGroupsQuery()
        
        // if given sort
        if let descending {
            // sort whole collection
            query = getAllSiteGroupsSortedByNameQuery(descending: descending)
        }
        print("Trying to query site groups collection.")
        return try await query
            .getDocuments(as: SiteGroup.self) // query site_groups collection
    }
    
    // get count of all sites
    // we can use this to determine if we need to use pagination
    func allSiteGroupsCount() async throws -> Int {
        try await siteGroupsCollection.aggregateCount()
    }
}
