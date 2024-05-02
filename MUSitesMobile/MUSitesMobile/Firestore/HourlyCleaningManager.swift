//
//  HourlyCleaningManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/18/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct HourlyCleaning: Identifiable, Codable, Equatable {
    let id: String
    let timestamp: Date?
    let userId: String?
    let siteId: String?
    let cleanedComputerIds: [String]?
    
    // create Site manually
    init(
        id: String,
        timestamp: Date? = nil,
        userId: String? = nil,
        siteId: String? = nil,
        cleanedComputerIds: [String]? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.userId = userId
        self.siteId = siteId
        self.cleanedComputerIds = cleanedComputerIds
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case timestamp = "timestamp"
        case userId = "user"
        case siteId = "computing_site"
        case cleanedComputerIds = "cleaned_computers"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
        self.siteId = try container.decodeIfPresent(String.self, forKey: .siteId)
        self.cleanedComputerIds = try container.decodeIfPresent([String].self, forKey: .cleanedComputerIds)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.timestamp, forKey: .timestamp)
        try container.encodeIfPresent(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.siteId, forKey: .siteId)
        try container.encodeIfPresent(self.cleanedComputerIds, forKey: .cleanedComputerIds)
    }
    
    static func == (lhs:HourlyCleaning, rhs: HourlyCleaning) -> Bool {
        // if two hourlyCleanings have the same ID, we're going to say they're equal to eachother
        return lhs.id == rhs.id
    }
}

final class HourlyCleaningManager {
    // create singleton of manager
    static let shared = HourlyCleaningManager()
    private init() { }
    
    // get the collection as CollectionReference
    private let hourlyCleaningsCollection: CollectionReference = Firestore.firestore().collection("hourly_cleanings")
    
    // get Firestore document as DocumentReference
    private func hourlyCleaningDocument(hourlyCleaningId: String) -> DocumentReference {
        hourlyCleaningsCollection.document(hourlyCleaningId)
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
    
    // get a hourlyCleaning from Firestore as HourlyCleaning struct
    func getHourlyCleaning(hourlyCleaningId: String) async throws -> HourlyCleaning {
        try await hourlyCleaningDocument(hourlyCleaningId: hourlyCleaningId).getDocument(as: HourlyCleaning.self)
    }
    
    // create a new hourlyCleaning in Firestore from struct
    func createHourlyCleaning(hourlyCleaning: HourlyCleaning) async throws {
        // connect to Firestore and create a new document from codable struct
        try hourlyCleaningDocument(hourlyCleaningId: hourlyCleaning.id).setData(from: hourlyCleaning, merge: false)
    }
    
    // fetch hourlyCleaning collection onto local device
    private func getAllHourlyCleaningsQuery() -> Query {
        hourlyCleaningsCollection
    }
    
    // create new hourlyCleaning document in Firestore, return id
    func getNewHourlyCleaningId() async throws -> String {
        // create auto-generated document in collection
        let document = hourlyCleaningsCollection.document()
        // get document id
        return document.documentID
    }
    
    // get hourlyCleanings filtered by date range
    private func getHourlyCleaningsBySiteQuery(startDate: Date, endDate: Date) -> Query {
        hourlyCleaningsCollection
            .whereField(HourlyCleaning.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(HourlyCleaning.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
    }
    
    // get hourlyCleanings filtered by site
    private func getHourlyCleaningsBySiteQuery(siteId: String) -> Query {
        hourlyCleaningsCollection
            .whereField(HourlyCleaning.CodingKeys.siteId.rawValue, isEqualTo: siteId)
    }
    
    // get hourlyCleanings sorted by Date
    private func getAllHourlyCleaningsSortedByDateQuery(descending: Bool) -> Query {
        hourlyCleaningsCollection
            .order(by: HourlyCleaning.CodingKeys.timestamp.rawValue, descending: descending)
    }
    
    // get hourlyCleanings filtered by site & sorted by date
    private func getAllHourlyCleaningsBySiteAndDateQuery(siteId: String, descending: Bool) -> Query {
        hourlyCleaningsCollection
            // filter by site
            .whereField(HourlyCleaning.CodingKeys.siteId.rawValue, isEqualTo: siteId)
            // sort by date
            .order(by: HourlyCleaning.CodingKeys.timestamp.rawValue, descending: descending)
    }
    
    // get hourlyCleanings filtered between dates & sorted by date
    private func getHourlyCleaningsSortedBetweenDatesQuery(dateDescending: Bool, startDate: Date, endDate: Date) -> Query {
        hourlyCleaningsCollection
            // filter for dates
            .whereField(HourlyCleaning.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(HourlyCleaning.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
            // order by dates
            .order(by: HourlyCleaning.CodingKeys.timestamp.rawValue, descending: dateDescending)
    }
    
    // get hourlyCleanings filtered between dates, filtered by site, & sorted by date
    private func getHourlyCleaningsSortedBetweenDatesBySiteQuery(siteId: String, dateDescending: Bool, startDate: Date, endDate: Date) -> Query {
        // The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/sitesmobile-4970/firestore/indexes?create_composite=Cllwcm9qZWN0cy9zaXRlc21vYmlsZS00OTcwL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9ob3VybHlfY2xlYW5pbmdzL2luZGV4ZXMvXxABGhIKDmNvbXB1dGluZ19zaXRlEAEaDQoJdGltZXN0YW1wEAIaDAoIX19uYW1lX18QAg
        hourlyCleaningsCollection
            // filter for dates
            .whereField(HourlyCleaning.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(HourlyCleaning.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
            // filter by site
            .whereField(HourlyCleaning.CodingKeys.siteId.rawValue, isEqualTo: siteId)
            // order by dates
            .order(by: HourlyCleaning.CodingKeys.timestamp.rawValue, descending: dateDescending)
    }
    
    // get hourlyCleanings by name
    func getAllHourlyCleanings(dateDescending: Bool?, siteId: String?,  startDate: Date?, endDate: Date?) async throws -> [HourlyCleaning] {
        // start with default query of entire collection
        var query: Query = getAllHourlyCleaningsQuery()
        
        // if given site, dateSort, & date range
        if let dateDescending, let siteId, let startDate, let endDate {
            // filter by site and date range, then sort by date
            query = getHourlyCleaningsSortedBetweenDatesBySiteQuery(siteId: siteId, dateDescending: dateDescending, startDate: startDate, endDate: endDate)
        // if given just date range & dateSort
        } else if let dateDescending, let startDate, let endDate {
            // filter and sort collection
            query = getHourlyCleaningsSortedBetweenDatesQuery(dateDescending: dateDescending, startDate: startDate, endDate: endDate)
        // if given just site & dateSort
        } else if let siteId, let dateDescending {
            // filter and sort collection
            query = getAllHourlyCleaningsBySiteAndDateQuery(siteId: siteId, descending: dateDescending)
        // if just given dateSort
        } else if let dateDescending {
            // sort whole collection
            query = getAllHourlyCleaningsSortedByDateQuery(descending: dateDescending)
        // if just given site
        } else if let siteId {
            // filter whole collection & sort assuming descending date
            query = getAllHourlyCleaningsBySiteAndDateQuery(siteId: siteId, descending: true)
        } else {
            // new default query: sort by ascending date
            query = getAllHourlyCleaningsSortedByDateQuery(descending: true)
        }
        
        print("Trying to query hourlyCleanings collection.")
        return try await query
            .getDocuments(as: HourlyCleaning.self) // query HourlyCleanings collection
    }
    
    // get hourlyCleanings filtered between dates, filtered by user
    func getHourlyCleaningsSortedBetweenDatesByUser(userId: String, startDate: Date, endDate: Date) async throws -> [HourlyCleaning] {
        // Error fetching hourlyCleanings: Error Domain=FIRFirestoreErrorDomain Code=9 "The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/sitesmobile-4970/firestore/indexes?create_composite=Cllwcm9qZWN0cy9zaXRlc21vYmlsZS00OTcwL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9ob3VybHlfY2xlYW5pbmdzL2luZGV4ZXMvXxABGggKBHVzZXIQARoNCgl0aW1lc3RhbXAQARoMCghfX25hbWVfXxAB" 
        let query = hourlyCleaningsCollection
            // filter for dates
            .whereField(HourlyCleaning.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(HourlyCleaning.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
            // filter by site
            .whereField(HourlyCleaning.CodingKeys.userId.rawValue, isEqualTo: userId)
        return try await query
            .getDocuments(as: HourlyCleaning.self)
    }
    
    // get count of all hourlyCleanings
    // we can use this to determine if we need to use pagination
    func allHourlyCleaningsCount() async throws -> Int {
        try await hourlyCleaningsCollection.aggregateCount()
    }
}
