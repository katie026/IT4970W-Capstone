//
//  SitesManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ChairCount: Codable {
    let count: Int
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case count = "chair_count"
        case type = "chair_type"
    }
}

struct Site: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String?
    let buildingId: String?
    let nearestInventoryId: String?
    let chairCounts: [ChairCount]?
    let siteTypeId: String?
    let hasClock: Bool?
    let hasInventory: Bool?
    let hasWhiteboard: Bool?
    let hasPosterBoard: Bool?
    let namePatternMac: String?
    let namePatternPc: String?
    let namePatternPrinter: String?
    let calendarName: String?
    var siteCaptain: String?
    
    // create Site manually
    init(
        id: String,
        name: String? = nil,
        buildingId: String? = nil,
        nearestInventoryId: String? = nil,
        chairCounts: [ChairCount]? = nil,
        siteTypeId: String? = nil,
        hasClock: Bool? = nil,
        hasInventory: Bool? = nil,
        hasWhiteboard: Bool? = nil,
        hasPosterBoard: Bool? = nil,
        namePatternMac: String? = nil,
        namePatternPc: String? = nil,
        namePatternPrinter: String? = nil,
        calendarName: String? = nil,
        siteCaptain: String? = nil
    ) {
        self.id = id
        self.name = name
        self.buildingId = buildingId
        self.nearestInventoryId = nearestInventoryId
        self.chairCounts = chairCounts
        self.siteTypeId = siteTypeId
        self.hasClock = hasClock
        self.hasInventory = hasInventory
        self.hasWhiteboard = hasWhiteboard
        self.hasPosterBoard = hasPosterBoard
        self.namePatternMac = namePatternMac
        self.namePatternPc = namePatternPc
        self.namePatternPrinter = namePatternPrinter
        self.calendarName = calendarName
        self.siteCaptain = siteCaptain
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case buildingId = "building"
        case nearestInventoryId = "nearest_inventory"
        case chairCounts = "chair_counts"
        case siteTypeId = "site_type"
        case hasClock = "has_clock"
        case hasInventory = "has_inventory"
        case hasWhiteboard = "has_whiteboard"
        case hasPosterBoard = "has_poster_board"
        case namePatternMac = "name_pattern_mac"
        case namePatternPc = "name_pattern_pc"
        case namePatternPrinter = "name_pattern_printer"
        case calendarName = "calendar_name"
        case siteCaptain = "site_captain"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.buildingId = try container.decodeIfPresent(String.self, forKey: .buildingId)
        self.nearestInventoryId = try container.decodeIfPresent(String.self, forKey: .nearestInventoryId)
        self.chairCounts = try container.decodeIfPresent([ChairCount].self, forKey: .chairCounts)
        self.siteTypeId = try container.decodeIfPresent(String.self, forKey: .siteTypeId)
        self.hasClock = try container.decodeIfPresent(Bool.self, forKey: .hasClock)
        self.hasInventory = try container.decodeIfPresent(Bool.self, forKey: .hasInventory)
        self.hasWhiteboard = try container.decodeIfPresent(Bool.self, forKey: .hasWhiteboard)
        self.hasPosterBoard = try container.decodeIfPresent(Bool.self, forKey: .hasPosterBoard)
        self.namePatternMac = try container.decodeIfPresent(String.self, forKey: .namePatternMac)
        self.namePatternPc = try container.decodeIfPresent(String.self, forKey: .namePatternPc)
        self.namePatternPrinter = try container.decodeIfPresent(String.self, forKey: .namePatternPrinter)
        self.calendarName = try container.decodeIfPresent(String.self, forKey: .calendarName)
        self.siteCaptain = try container.decodeIfPresent(String.self, forKey: .siteCaptain)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.buildingId, forKey: .buildingId)
        try container.encodeIfPresent(self.nearestInventoryId, forKey: .nearestInventoryId)
        try container.encodeIfPresent(self.chairCounts, forKey: .chairCounts)
        try container.encodeIfPresent(self.siteTypeId, forKey: .siteTypeId)
        try container.encodeIfPresent(self.hasClock, forKey: .hasClock)
        try container.encodeIfPresent(self.hasInventory, forKey: .hasInventory)
        try container.encodeIfPresent(self.hasWhiteboard, forKey: .hasWhiteboard)
        try container.encodeIfPresent(self.hasPosterBoard, forKey: .hasPosterBoard)
        try container.encodeIfPresent(self.namePatternMac, forKey: .namePatternMac)
        try container.encodeIfPresent(self.namePatternPc, forKey: .namePatternPc)
        try container.encodeIfPresent(self.namePatternPrinter, forKey: .namePatternPrinter)
        try container.encodeIfPresent(self.calendarName, forKey: .calendarName)
        try container.encodeIfPresent(self.siteCaptain, forKey: .siteCaptain)
    }
    
    // Equatable
    static func == (lhs:Site, rhs: Site) -> Bool {
        // if two sites have the same ID, we're going to say they're equal to eachother
        return lhs.id == rhs.id
    }
    
    // Hashable
    func hash(into hasher: inout Hasher) {
        // Combine the hash values of all properties that contribute to the uniqueness of the Site
        hasher.combine(id)
        hasher.combine(name)
    }
}

final class SitesManager {
    // create singleton of manager
    static let shared = SitesManager()
    private init() { }
    
    // get the collection as CollectionReference
    private let sitesCollection: CollectionReference = Firestore.firestore().collection("computing_sites")
    
    // get Firestore document as DocumentReference
    private func siteDocument(siteId: String) -> DocumentReference {
        sitesCollection.document(siteId)
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
    
    // get a site from Firestore as Site struct
    func getSite(siteId: String) async throws -> Site {
        try await siteDocument(siteId: siteId).getDocument(as: Site.self)
    }
    
    // create a new site in Firestore from struct
    func createSite(site: Site) async throws {
        // connect to Firestore and create a new document from codable struct
        try siteDocument(siteId: site.id).setData(from: site, merge: false)
    }
    
    // fetch site collection onto local device
    private func getAllSitesQuery() -> Query {
        sitesCollection
    }
    
    // get sites sorted by Name
    private func getAllSitesSortedByNameQuery(descending: Bool) -> Query {
        sitesCollection
            .order(by: Site.CodingKeys.name.rawValue, descending: descending)
    }
    
    // get sites by name
    func getAllSites(descending: Bool?) async throws -> [Site] {
        var query: Query = getAllSitesQuery()
        
        // if given sort
        if let descending {
            // sort whole collection
            query = getAllSitesSortedByNameQuery(descending: descending)
        }
        
        print("Trying to query sites collection.")
        return try await query
            .getDocuments(as: Site.self) // query Sites collection
    }
    
    // get count of all sites
    // we can use this to determine if we need to use pagination
    func allSitesCount() async throws -> Int {
        try await sitesCollection.aggregateCount()
    }
    
    // get sites by building
    func getSitesByBuilding(buildingId: String) async throws -> [Site] {
        let query = sitesCollection
            .whereField(Site.CodingKeys.buildingId.rawValue, isEqualTo: buildingId)
        
        return try await query
            .getDocuments(as: Site.self)
    }
    
    // check if sites in Building
    func checkIfSitesInBuilding(buildingId: String, completion: @escaping (Bool) -> Void) {
        let query = sitesCollection
                .whereField(Site.CodingKeys.buildingId.rawValue, isEqualTo: buildingId)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching computing sites: \(error)")
                completion(false)
                return
            }
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                completion(false)
                return
            }
            
            // Check if any documents exist in the snapshot
            completion(!snapshot.documents.isEmpty) // return true if any sites were returned for that buildingId
        }
    }
}
