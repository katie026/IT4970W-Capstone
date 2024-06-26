//
//  SupplyRequestManager.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 4/20/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SupplyRequest: Identifiable, Codable, Equatable {
    var id: String
    let siteId: String?
    var supplyTypeId: String?
    var countNeeded: Int?
    var reportId: String?
    let reportType: String?
    var resolved: Bool?
    let dateCreated: Date?
    var dateResolved: Date?
    var userAssigned: String?

    init(
        id: String,
        siteId: String? = nil,
        supplyTypeId: String? = nil,
        countNeeded: Int? = nil,
        reportId: String? = nil,
        reportType: String? = nil,
        resolved: Bool? = nil,
        dateCreated: Date? = nil,
        dateResolved: Date? = nil,
        userAssigned: String? = nil
    )
    {
        self.id = id
        self.siteId = siteId
        self.supplyTypeId = supplyTypeId
        self.countNeeded = countNeeded
        self.reportId = reportId
        self.reportType = reportType
        self.resolved = resolved
        self.dateResolved = dateResolved
        self.dateCreated = dateCreated
        self.userAssigned = userAssigned
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case siteId = "site"
        case supplyTypeId = "supply_type"
        case countNeeded = "count_needed"
        case reportId = "report_id"
        case reportType = "report_type"
        case resolved = "resolved"
        case dateCreated = "date_created"
        case dateResolved = "date_resolved"
        case userAssigned = "user_assigned"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.siteId = try container.decodeIfPresent(String.self, forKey: .siteId)
        self.supplyTypeId = try container.decodeIfPresent(String.self, forKey: .supplyTypeId)
        self.countNeeded = try container.decodeIfPresent(Int.self, forKey: .countNeeded)
        self.reportId = try container.decodeIfPresent(String.self, forKey: .reportId)
        self.reportType = try container.decodeIfPresent(String.self, forKey: .reportType)
        self.resolved = try container.decodeIfPresent(Bool.self, forKey: .resolved)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.dateResolved = try container.decodeIfPresent(Date.self, forKey: .dateResolved)
        self.userAssigned = try container.decodeIfPresent(String.self, forKey: .userAssigned)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.siteId, forKey: .siteId)
        try container.encodeIfPresent(self.supplyTypeId, forKey: .supplyTypeId)
        try container.encodeIfPresent(self.countNeeded, forKey: .countNeeded)
        try container.encodeIfPresent(self.reportId, forKey: .reportId)
        try container.encodeIfPresent(self.reportType, forKey: .reportType)
        try container.encodeIfPresent(self.resolved, forKey: .resolved)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.dateResolved, forKey: .dateResolved)
        try container.encodeIfPresent(self.userAssigned, forKey: .userAssigned)
    }
    
    static func == (lhs:SupplyRequest, rhs: SupplyRequest) -> Bool {
        // if two issues have the same ID, we're going to say they're equal to eachother
        return lhs.id == rhs.id
    }
}

final class SupplyRequestManager {
    // create singleton of manager
    static let shared = SupplyRequestManager()
    private init() { }
    
    // get the collection as CollectionReference
    private let supplyRequestsCollection: CollectionReference = Firestore.firestore().collection("supply_requests")
    
    // get Firestore document as DocumentReference
    private func supplyRequestDocument(supplyRequestId: String) -> DocumentReference {
        supplyRequestsCollection.document(supplyRequestId)
    }
    
    // create Firestore encoder
    private let encoder: Firestore.Encoder = Firestore.Encoder()
    
    // create Firestore decoder
    private let decoder: Firestore.Decoder = Firestore.Decoder()
    
    // get a supplyRequest from Firestore as SupplyRequest struct
    func getSupplyRequest(supplyRequestId: String) async throws -> SupplyRequest {
        try await supplyRequestDocument(supplyRequestId: supplyRequestId).getDocument(as: SupplyRequest.self)
    }
    
    // create a new supplyRequest in Firestore from struct
    func createSupplyRequest(supplyRequest: SupplyRequest) async throws {
        // connect to Firestore and create a new document from codable struct
        try supplyRequestDocument(supplyRequestId: supplyRequest.id).setData(from: supplyRequest, merge: false)
    }
    
    // delete an supplyRequest from Firestore
    func deleteSupplyRequest(supplyRequestId: String) async throws {
        try await supplyRequestDocument(supplyRequestId: supplyRequestId).delete()
    }
    
    // fetch supplyRequest collection onto local device
    private func getAllSupplyRequestsQuery() -> Query {
        supplyRequestsCollection
    }
    
    // create new supplyRequest document in Firestore, return id
    func getNewSupplyRequestId() async throws -> String {
        // create auto-generated document in collection
        let document = supplyRequestsCollection.document()
        // get document id
        return document.documentID
    }
    
    // get hourlyCleanings sorted by Date
    private func getSupplyRequestsSortedByDateQuery(descending: Bool) -> Query {
        supplyRequestsCollection
            .order(by: SupplyRequest.CodingKeys.dateCreated.rawValue, descending: descending)
    }
    
    // get supplyRequests filtered by date range
    private func getSupplyRequestsByDateQuery(startDate: Date, endDate: Date) -> Query {
        supplyRequestsCollection
            .whereField(SupplyRequest.CodingKeys.dateCreated.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(SupplyRequest.CodingKeys.dateCreated.rawValue, isLessThanOrEqualTo: endDate)
    }
    
    // get supplyRequests filtered by date & sorted by date
    private func getSupplyRequestsSortedFilteredByDateQuery(descending: Bool, startDate: Date, endDate: Date) -> Query {
        supplyRequestsCollection
            // filter by date
            .whereField(SupplyRequest.CodingKeys.dateCreated.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(SupplyRequest.CodingKeys.dateCreated.rawValue, isLessThanOrEqualTo: endDate)
            // sort by date
            .order(by: SupplyRequest.CodingKeys.dateCreated.rawValue, descending: descending)
    }
    
    // get supplyRequests sorted by date
    private func getAllSupplyRequestsSortedByNameQuery(descending: Bool) -> Query {
        supplyRequestsCollection
            .order(by: SupplyRequest.CodingKeys.dateCreated.rawValue, descending: descending)
    }
    
    // get supplyRequests by name
    func getAllSupplyRequests(descending: Bool?, startDate: Date?, endDate: Date?) async throws -> [SupplyRequest] {
        var query: Query = getAllSupplyRequestsQuery()
        
        // if given a Site and nameSort
        if let descending, let startDate, let endDate {
            // filter and sort collection
            query = getSupplyRequestsSortedFilteredByDateQuery(descending: descending, startDate: startDate, endDate: endDate)
        // if just given sort
        } else if let descending {
            // sort whole collection
            query = getSupplyRequestsSortedByDateQuery(descending: descending)
        // if just given filter
        } else if let startDate, let endDate {
            // filter whole collection
            query = getSupplyRequestsByDateQuery(startDate: startDate, endDate: endDate)
        }
        
        print("Trying to query supplyRequests collection.")
        return try await query
            .getDocuments(as: SupplyRequest.self) // query SupplyRequests collection
    }
    
    // get count of all supplyRequests
    // we can use this to determine if we need to use pagination
    func allSupplyRequestsCount() async throws -> Int {
        try await supplyRequestsCollection.aggregateCount()
    }
    
    func updateSupplyRequest(_ supplyRequest: SupplyRequest) async throws {
        // Get the reference to the document
        let documentRef = supplyRequestDocument(supplyRequestId: supplyRequest.id)
        
        // Encode the updated SiteCapatin object
        guard let data = try? encoder.encode(supplyRequest) else {
            // Handle encoding error
            throw SupplyRequestManagerError.encodingError
        }
            
        // Set the data for the document
        try await documentRef.setData(data)
    }
    
    func updateSupplyRequests(_ supplyRequests: [SupplyRequest]) async throws {
        // Create a new batched write operation
        let batch = Firestore.firestore().batch()
        
        // Iterate over the supplyRequests array and update each document in the batch
        for supplyRequest in supplyRequests {
            // Get the reference to the document
            let documentRef = supplyRequestDocument(supplyRequestId: supplyRequest.id)
            
            // Encode the updated supplyCount object
            guard let data = try? encoder.encode(supplyRequest) else {
                // Handle encoding error
                throw SupplyRequestManagerError.encodingError
            }
            
            // Set the data for the document in the batch
            batch.setData(data, forDocument: documentRef)
        }
        
        // Commit the batched write operation
        try await batch.commit()
    }
    
    func toggleResolution(supplyRequest: SupplyRequest) async throws {
        var supplyRequest = supplyRequest
        
        // if supplyRequest is resolved (if .resolved is nil, assume it's not resolved
        if supplyRequest.resolved ?? false {
            // mark supplyRequest as unresolved
            supplyRequest.resolved = false
            // erase dateResolved
            supplyRequest.dateResolved = nil
        // if supplyRequest is not resolved
        } else {
            // mark supplyRequest as resolved
            supplyRequest.resolved = true
            // update dateResolved
            supplyRequest.dateResolved = Date()
        }
        
        // update issue in Firestore
        try await updateSupplyRequest(supplyRequest)
    }
    
    // Delete a batch of issues from Firestore
    func deleteSupplyRequests(supplyRequestIds: [String]) async throws {
        // Create a new batched write operation
        let batch = Firestore.firestore().batch()
        
        // Iterate over the issue IDs array and delete each document in the batch
        for supplyRequestId in supplyRequestIds {
            // Get the reference to the document
            let documentRef = supplyRequestDocument(supplyRequestId: supplyRequestId)
            
            // Delete the document in the batch
            batch.deleteDocument(documentRef)
        }
        
        // Commit the batched write operation
        try await batch.commit()
    }
}

// Errors
enum SupplyRequestManagerError: Error {
    case noSupplyRequestId
    case encodingError
}
