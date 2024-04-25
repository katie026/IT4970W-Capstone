//
//  SiteCaptainManager.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/25/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

struct SiteCaptain: Codable {
    let id: String
    let siteId: String?
    let issues: [String]?
    let supplyRequests: [String]?
    let timestamp: Date?
    let updatedInventory: Bool?
    let user: String?
    
    init(
        id: String,
        siteId:String? = nil,
        issues: [String]? = nil,
        supplyRequests:[String]? = nil,
        timestamp : Date? = nil,
        updatedInventory: Bool? = nil,
        user : String? = nil
        
    ) {
        
        self.id = id
        self.siteId = siteId
        self.issues = issues
        self.supplyRequests = supplyRequests
        self.timestamp = timestamp
        self.updatedInventory = updatedInventory
        self.user = user
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case siteId = "site_id"
        case issues = "issues"
        case supplyRequests = "supply_requests"
        case timestamp = "timestamp"
        case updatedInventory = "updated_inventory"
        case user = "user"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.siteId = try container.decodeIfPresent(String.self, forKey: .siteId)
        self.issues = try container.decodeIfPresent([String].self, forKey: .issues)
        self.supplyRequests = try container.decodeIfPresent([String].self, forKey: .supplyRequests)
        self.timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp)
        self.updatedInventory = try container.decodeIfPresent(Bool.self, forKey: .updatedInventory)
        self.user = try container.decodeIfPresent(String.self, forKey: .user)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.siteId, forKey: .siteId)
        try container.encodeIfPresent(self.issues, forKey: .issues)
        try container.encodeIfPresent(self.supplyRequests, forKey: .supplyRequests)
        try container.encodeIfPresent(self.timestamp, forKey: .timestamp)
        try container.encodeIfPresent(self.updatedInventory, forKey: .updatedInventory)
        try container.encodeIfPresent(self.user, forKey: .user)
    }
}

struct SiteCaptainIssue: Codable {
    let issue: String
    let ticket: String
}

struct SupplyNeeded: Codable {
    let count: Int
    let supply: String
}


class SiteCaptainManager {
    // create singleton of manager
    static let shared = SiteCaptainManager()
    private init() { }
    
    // get the collection as CollectionReference
    private let siteCaptainsCollection: CollectionReference = Firestore.firestore().collection("site_captain_entries")
    
    // get Firestore document as DocumentReference
    private func siteCaptainDocument(siteCaptainId: String) -> DocumentReference {
        siteCaptainsCollection.document(siteCaptainId)
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
    
    // get a siteCaptain from Firestore as SiteCaptain struct
    func getSiteCaptain(siteCaptainId: String) async throws -> SiteCaptain {
        try await siteCaptainDocument(siteCaptainId: siteCaptainId).getDocument(as: SiteCaptain.self)
    }
    
    // create a new siteCaptain in Firestore from struct
    func createSiteCaptain(siteCaptain: SiteCaptain) async throws {
        // connect to Firestore and create a new document from codable struct
        try siteCaptainDocument(siteCaptainId: siteCaptain.id).setData(from: siteCaptain, merge: false)
    }
    
    // fetch siteCaptain collection onto local device
    private func getAllSiteCaptainsQuery() -> Query {
        siteCaptainsCollection
    }
    
    // create new siteCaptain document in Firestore, return id
    func getNewSiteCaptainId() async throws -> String {
        // create auto-generated document in collection
        let document = siteCaptainsCollection.document()
        // get document id
        return document.documentID
    }
    
    // get hourlyCleanings sorted by Date
    private func getSiteCaptainsSortedByDateQuery(descending: Bool) -> Query {
        siteCaptainsCollection
            .order(by: SiteCaptain.CodingKeys.timestamp.rawValue, descending: descending)
    }
    
    // get siteCaptains filtered by date range
    private func getSiteCaptainsByDateQuery(startDate: Date, endDate: Date) -> Query {
        siteCaptainsCollection
            .whereField(SiteCaptain.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(SiteCaptain.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
    }
    
    // get siteCaptains filtered by date & sorted by date
    private func getSiteCaptainsSortedFilteredByDateQuery(descending: Bool, startDate: Date, endDate: Date) -> Query {
        siteCaptainsCollection
            // filter by date
            .whereField(SiteCaptain.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(SiteCaptain.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
            // sort by date
            .order(by: SiteCaptain.CodingKeys.timestamp.rawValue, descending: descending)
    }
    
    // get siteCaptains sorted by date
    private func getAllSiteCaptainsSortedByNameQuery(descending: Bool) -> Query {
        siteCaptainsCollection
            .order(by: SiteCaptain.CodingKeys.timestamp.rawValue, descending: descending)
    }
    
    // get siteCaptains by name
    func getAllSiteCaptains(descending: Bool?, startDate: Date?, endDate: Date?) async throws -> [SiteCaptain] {
        var query: Query = getAllSiteCaptainsQuery()
        
        // if given a Site and nameSort
        if let descending, let startDate, let endDate {
            // filter and sort collection
            query = getSiteCaptainsSortedFilteredByDateQuery(descending: descending, startDate: startDate, endDate: endDate)
        // if just given sort
        } else if let descending {
            // sort whole collection
            query = getSiteCaptainsSortedByDateQuery(descending: descending)
        // if just given filter
        } else if let startDate, let endDate {
            // filter whole collection
            query = getSiteCaptainsByDateQuery(startDate: startDate, endDate: endDate)
        }
        
        print("Trying to query siteCaptains collection.")
        return try await query
            .getDocuments(as: SiteCaptain.self) // query SiteCaptains collection
    }
    
    // get count of all siteCaptains
    // we can use this to determine if we need to use pagination
    func allSiteCaptainsCount() async throws -> Int {
        try await siteCaptainsCollection.aggregateCount()
    }
    
    func updateSiteCaptain(_ siteCaptain: SiteCaptain) async throws {
        // Get the reference to the document
        let documentRef = siteCaptainDocument(siteCaptainId: siteCaptain.id)
        
        // Encode the updated SiteCapatin object
        guard let data = try? encoder.encode(siteCaptain) else {
            // Handle encoding error
            throw SiteCaptainManagerError.encodingError
        }
            
        // Set the data for the document
        try await documentRef.setData(data)
    }
    
    func updateSiteCaptains(_ siteCaptains: [SiteCaptain]) async throws {
        // Create a new batched write operation
        let batch = Firestore.firestore().batch()
        
        // Iterate over the siteCaptains array and update each document in the batch
        for siteCaptain in siteCaptains {
            // Get the reference to the document
            let documentRef = siteCaptainDocument(siteCaptainId: siteCaptain.id)
            
            // Encode the updated supplyCount object
            guard let data = try? encoder.encode(siteCaptain) else {
                // Handle encoding error
                throw SiteCaptainManagerError.encodingError
            }
            
            // Set the data for the document in the batch
            batch.setData(data, forDocument: documentRef)
        }
        
        // Commit the batched write operation
        try await batch.commit()
    }
    
//    private let db = Firestore.firestore()
//    private let siteCaptainEntry = "site_captain_entries"
//    private let supplyRequestCollection = "supply_requests"
//    
//    func submitSiteCaptainEntry(_ computingSite: SiteCaptain, completion: @escaping (Error?) -> Void) {
//        do {
//            try db.collection(siteCaptainEntry).document(computingSite.id).setData(from: computingSite) { [weak self] error in
//                if let error = error {
//                    print("Error submitting site captain entry: \(error.localizedDescription)")
//                    completion(error)
//                } else {
//                    print("Site captain entry submitted successfully!")
////                    self?.createSupplyRequests(for: computingSite, completion: completion)
//                }
//            }
//        } catch {
//            print("Error encoding site captain entry: \(error.localizedDescription)")
//            completion(error)
//        }
//    }
    
//    private func createSupplyRequests(for computingSite: SiteCaptain, completion: @escaping (Error?) -> Void) {
//        let supplyRequests = computingSite.suppliesNeeded.map { supplyNeeded -> SupplyRequest in
//            return SupplyRequest(
//                id: UUID().uuidString,
//                countNeeded: supplyNeeded.count,
//                reportID: computingSite.id,
//                reportType: "site_captain",
//                resolved: false,
//                supplyType: supplyNeeded.supply
//            )
//        }
//        
//        let batch = db.batch()
//        
//        for supplyRequest in supplyRequests {
//            let supplyRequestRef = db.collection(supplyRequestCollection).document(supplyRequest.id)
//            batch.setData(try! Firestore.Encoder().encode(supplyRequest), forDocument: supplyRequestRef)
//        }
//        
//        batch.commit { error in
//            if let error = error {
//                print("Error creating supply requests: \(error.localizedDescription)")
//                completion(error)
//            } else {
//                print("Supply requests created successfully!")
//                completion(nil)
//            }
//        }
//    }
}

// Errors
enum SiteCaptainManagerError: Error {
    case noSiteCaptainId
    case encodingError
}
