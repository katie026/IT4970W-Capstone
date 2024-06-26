//
//  SiteReadyManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/27/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

struct PosterReport: Codable, Hashable {
    var posterType: String?
    var status: String?
    
    enum CodingKeys: String, CodingKey {
        case posterType = "poster_type"
        case status = "status"
    }
}

struct EquipmentStatus: Codable {
    var equipment: String?
    var status: String?
}

struct SiteReady: Codable, Identifiable {
    let id: String
    let timestamp: Date?
    let user: String?
    let siteId: String?
    let macCount: Int?
    let pcCount: Int?
    let scannerCount: Int?
    let scannerComputers: [String]?
    let bwPrinterCount: Int?
    let colorPrinterCount: Int?
    let chairCount: Int?
    let missingChairs: Int?
    let updatedInventory: Bool?
    let posters: [PosterReport]?
    let supplyRequests: [String]?
    let equipmentStatuses: [EquipmentStatus]?
    let issues: [String]?
    let comments: String?
    
    init(
        id: String,
        timestamp: Date? = nil,
        user: String? = nil,
        siteId: String? = nil,
        macCount: Int? = nil,
        pcCount: Int? = nil,
        scannerCount: Int? = nil,
        scannerComputers: [String]? = nil,
        bwPrinterCount: Int? = nil,
        colorPrinterCount: Int? = nil,
        chairCount: Int? = nil,
        missingChairs: Int? = nil,
        updatedInventory: Bool? = nil,
        posters: [PosterReport]? = nil,
        supplyRequests: [String]? = nil,
        equipmentStatuses: [EquipmentStatus]? = nil,
        issues: [String]? = nil,
        comments: String? = nil
    ) {
        
        self.id = id
        self.timestamp = timestamp
        self.user = user
        self.siteId = siteId
        self.macCount = macCount
        self.pcCount = pcCount
        self.scannerCount = scannerCount
        self.scannerComputers = scannerComputers
        self.bwPrinterCount = bwPrinterCount
        self.colorPrinterCount = colorPrinterCount
        self.chairCount = chairCount
        self.missingChairs = missingChairs
        self.updatedInventory = updatedInventory
        self.posters = posters
        self.supplyRequests = supplyRequests
        self.equipmentStatuses = equipmentStatuses
        self.issues = issues
        self.comments = comments
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case timestamp = "timestamp"
        case user = "user"
        case siteId = "computing_site"
        case macCount = "mac_count"
        case pcCount = "pc_count"
        case scannerCount = "scanner_count"
        case scannerComputers = "scanner_computers"
        case bwPrinterCount = "bw_printer_count"
        case colorPrinterCount = "color_printer_count"
        case chairCount = "chair_count"
        case missingChairs = "missing_chairs"
        case updatedInventory = "updated_inventory"
        case posters = "posters"
        case supplyRequests = "supply_requests"
        case equipmentStatuses = "equipment_status"
        case issues = "issues"
        case comments = "comments"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.timestamp, forKey: .timestamp)
        try container.encodeIfPresent(self.user, forKey: .user)
        try container.encodeIfPresent(self.siteId, forKey: .siteId)
        try container.encodeIfPresent(self.macCount, forKey: .macCount)
        try container.encodeIfPresent(self.pcCount, forKey: .pcCount)
        try container.encodeIfPresent(self.scannerCount, forKey: .scannerCount)
        try container.encodeIfPresent(self.scannerComputers, forKey: .scannerComputers)
        try container.encodeIfPresent(self.bwPrinterCount, forKey: .bwPrinterCount)
        try container.encodeIfPresent(self.colorPrinterCount, forKey: .colorPrinterCount)
        try container.encodeIfPresent(self.chairCount, forKey: .chairCount)
        try container.encodeIfPresent(self.missingChairs, forKey: .missingChairs)
        try container.encodeIfPresent(self.updatedInventory, forKey: .updatedInventory)
        try container.encodeIfPresent(self.posters, forKey: .posters)
        try container.encodeIfPresent(self.supplyRequests, forKey: .supplyRequests)
        try container.encodeIfPresent(self.equipmentStatuses, forKey: .equipmentStatuses)
        try container.encodeIfPresent(self.issues, forKey: .issues)
        try container.encodeIfPresent(self.comments, forKey: .comments)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp)
        self.user = try container.decodeIfPresent(String.self, forKey: .user)
        self.siteId = try container.decodeIfPresent(String.self, forKey: .siteId)
        self.macCount = try container.decodeIfPresent(Int.self, forKey: .macCount)
        self.pcCount = try container.decodeIfPresent(Int.self, forKey: .pcCount)
        self.scannerCount = try container.decodeIfPresent(Int.self, forKey: .scannerCount)
        self.scannerComputers = try container.decodeIfPresent([String].self, forKey: .scannerComputers)
        self.bwPrinterCount = try container.decodeIfPresent(Int.self, forKey: .bwPrinterCount)
        self.colorPrinterCount = try container.decodeIfPresent(Int.self, forKey: .colorPrinterCount)
        self.chairCount = try container.decodeIfPresent(Int.self, forKey: .chairCount)
        self.missingChairs = try container.decodeIfPresent(Int.self, forKey: .missingChairs)
        self.updatedInventory = try container.decodeIfPresent(Bool.self, forKey: .updatedInventory)
        self.posters = try container.decodeIfPresent([PosterReport].self, forKey: .posters)
        self.supplyRequests = try container.decodeIfPresent([String].self, forKey: .supplyRequests)
        self.equipmentStatuses = try container.decodeIfPresent([EquipmentStatus].self, forKey: .equipmentStatuses)
        self.issues = try container.decodeIfPresent([String].self, forKey: .issues)
        self.comments = try container.decodeIfPresent(String.self, forKey: .comments)
    }
}

enum SiteReadySearchOption: String, CaseIterable, Hashable {
    case user
    
    var optionLabel: String {
        switch self {
        case .user: return "User"
        }
    }
}

class SiteReadyManager {
    // create singleton of manager
    static let shared = SiteReadyManager()
    private init() { }
    
    // get the collection as CollectionReference
    private let siteReadysCollection: CollectionReference = Firestore.firestore().collection("site_ready_entries")
    
    // get Firestore document as DocumentReference
    private func siteReadyDocument(siteReadyId: String) -> DocumentReference {
        siteReadysCollection.document(siteReadyId)
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
    
    // get a siteReady from Firestore as SiteReady struct
    func getSiteReady(siteReadyId: String) async throws -> SiteReady {
        try await siteReadyDocument(siteReadyId: siteReadyId).getDocument(as: SiteReady.self)
    }
    
    // create a new siteReady in Firestore from struct
    func createSiteReady(siteReady: SiteReady) async throws {
        // connect to Firestore and create a new document from codable struct
        try siteReadyDocument(siteReadyId: siteReady.id).setData(from: siteReady, merge: false)
    }
    
    // fetch siteReady collection onto local device
    private func getAllSiteReadysQuery() -> Query {
        siteReadysCollection
    }
    
    // create new siteReady document in Firestore, return id
    func getNewSiteReadyId() async throws -> String {
        // create auto-generated document in collection
        let document = siteReadysCollection.document()
        // get document id
        return document.documentID
    }
    
    // get siteReadys sorted by Date
    private func getSiteReadysSortedByDateQuery(dateDescending: Bool) -> Query {
        siteReadysCollection
            .order(by: SiteReady.CodingKeys.timestamp.rawValue, descending: dateDescending)
    }
    
    // get siteReadys filtered by date range
    private func getSiteReadysBetweenDatesQuery(startDate: Date, endDate: Date) -> Query {
        siteReadysCollection
            .whereField(SiteReady.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(SiteReady.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
    }
    
    // get siteReadys filtered by site & sorted by date
    private func getSiteReadysBySiteAndDateQuery(siteId: String, dateDescending: Bool) -> Query {
        siteReadysCollection
            // filter by site
            .whereField(SiteReady.CodingKeys.siteId.rawValue, isEqualTo: siteId)
            // sort by date
            .order(by: SiteReady.CodingKeys.timestamp.rawValue, descending: dateDescending)
    }
    
    // get siteReadys filtered by date & sorted by date
    private func getSiteReadysSortedFilteredByDateQuery(dateDescending: Bool, startDate: Date, endDate: Date) -> Query {
        siteReadysCollection
            // filter by date
            .whereField(SiteReady.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(SiteReady.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
            // sort by date
            .order(by: SiteReady.CodingKeys.timestamp.rawValue, descending: dateDescending)
    }
    
    // get siteReadys sorted by date
    private func getSiteReadysSortedByNameQuery(descending: Bool) -> Query {
        siteReadysCollection
            .order(by: SiteReady.CodingKeys.timestamp.rawValue, descending: descending)
    }
    
    // get siteReadys filtered between dates & sorted by date
    private func getSiteReadysSortedBetweenDatesQuery(dateDescending: Bool, startDate: Date, endDate: Date) -> Query {
        siteReadysCollection
            // filter for dates
            .whereField(SiteReady.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(SiteReady.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
            // order by dates
            .order(by: SiteReady.CodingKeys.timestamp.rawValue, descending: dateDescending)
    }
    
    // get siteReadys filtered between dates, filtered by site, & sorted by date
    private func getSiteReadysSortedBetweenDatesBySiteQuery(siteId: String, dateDescending: Bool, startDate: Date, endDate: Date) -> Query {
        // The query requires an index. You can create it here:
        siteReadysCollection
            // filter for dates
            .whereField(SiteReady.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(SiteReady.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
            // filter by site
            .whereField(SiteReady.CodingKeys.siteId.rawValue, isEqualTo: siteId)
            // order by dates
            .order(by: SiteReady.CodingKeys.timestamp.rawValue, descending: dateDescending)
    }
    
    // get siteReadys by name
    func getAllSiteReadys(dateDescending: Bool?, siteId: String?, startDate: Date?, endDate: Date?) async throws -> [SiteReady] {
        // start with default query of entire collection
        var query: Query = getAllSiteReadysQuery()
        
        // if given site, dateSort, & date range
        if let dateDescending, let siteId, let startDate, let endDate {
            // filter by site and date range, then sort by date
            query = getSiteReadysSortedBetweenDatesBySiteQuery(siteId: siteId, dateDescending: dateDescending, startDate: startDate, endDate: endDate)
        // if given just date range & dateSort
        } else if let dateDescending, let startDate, let endDate {
            // filter and sort collection
            query = getSiteReadysSortedBetweenDatesQuery(dateDescending: dateDescending, startDate: startDate, endDate: endDate)
        // if given just site & dateSort
        } else if let siteId, let dateDescending {
            // filter and sort collection
            query = getSiteReadysBySiteAndDateQuery(siteId: siteId, dateDescending: dateDescending)
        // if just given dateSort
        } else if let dateDescending {
            // sort whole collection
            query = getSiteReadysSortedByDateQuery(dateDescending: dateDescending)
        // if just given site
        } else if let siteId {
            // filter whole collection & sort assuming descending date
            query = getSiteReadysBySiteAndDateQuery(siteId: siteId, dateDescending: true)
        } else {
            // new default query: sort by ascending date
            query = getSiteReadysSortedByDateQuery(dateDescending: true)
        }
        
        print("Trying to query siteReadys collection.")
        return try await query
            .getDocuments(as: SiteReady.self) // query SiteReadys collection
    }
    
    // get count of all siteReadys
    // we can use this to determine if we need to use pagination
    func allSiteReadysCount() async throws -> Int {
        try await siteReadysCollection.aggregateCount()
    }
    
    func updateSiteReady(_ siteReady: SiteReady) async throws {
        // Get the reference to the document
        let documentRef = siteReadyDocument(siteReadyId: siteReady.id)
        
        // Encode the updated SiteCapatin object
        guard let data = try? encoder.encode(siteReady) else {
            // Handle encoding error
            throw SiteReadyManagerError.encodingError
        }
            
        // Set the data for the document
        try await documentRef.setData(data)
    }
    
    func updateSiteReadys(_ siteReadys: [SiteReady]) async throws {
        // Create a new batched write operation
        let batch = Firestore.firestore().batch()
        
        // Iterate over the siteReadys array and update each document in the batch
        for siteReady in siteReadys {
            // Get the reference to the document
            let documentRef = siteReadyDocument(siteReadyId: siteReady.id)
            
            // Encode the updated supplyCount object
            guard let data = try? encoder.encode(siteReady) else {
                // Handle encoding error
                throw SiteReadyManagerError.encodingError
            }
            
            // Set the data for the document in the batch
            batch.setData(data, forDocument: documentRef)
        }
        
        // Commit the batched write operation
        try await batch.commit()
    }
}

// Errors
enum SiteReadyManagerError: Error {
    case noSiteReadyId
    case encodingError
}
