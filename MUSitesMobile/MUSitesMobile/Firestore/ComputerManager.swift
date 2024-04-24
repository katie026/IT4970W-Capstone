//
//  ComputerManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/13/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Computer: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String?
    let os: String?
    let siteId: String?
    var lastCleaned: Date?
    let section: String?
    
    // create Site manually
    init(
        id: String,
        name: String? = nil,
        os: String? = nil,
        siteId: String? = nil,
        lastCleaned: Date? = nil,
        section: String? = nil
    ) {
        self.id = id
        self.name = name
        self.os = os
        self.siteId = siteId
        self.lastCleaned = lastCleaned
        self.section = section
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "computer_name"
        case os = "OS"
        case siteId = "computing_site"
        case lastCleaned = "last_cleaned"
        case section = "section"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.os = try container.decodeIfPresent(String.self, forKey: .os)
        self.siteId = try container.decodeIfPresent(String.self, forKey: .siteId)
        self.lastCleaned = try container.decodeIfPresent(Date.self, forKey: .lastCleaned)
        self.section = try container.decodeIfPresent(String.self, forKey: .section)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.os, forKey: .os)
        try container.encodeIfPresent(self.siteId, forKey: .siteId)
        try container.encodeIfPresent(self.lastCleaned, forKey: .lastCleaned)
        try container.encodeIfPresent(self.section, forKey: .section)
    }
    
    static func == (lhs:Computer, rhs: Computer) -> Bool {
        // if two computers have the same ID, we're going to say they're equal to eachother
        return lhs.id == rhs.id
    }
}

final class ComputerManager {
    // create singleton of manager
    static let shared = ComputerManager()
    private init() { }
    
    // get the collection as CollectionReference
    private let computersCollection: CollectionReference = Firestore.firestore().collection("computers")
    
    // get Firestore document as DocumentReference
    private func computerDocument(computerId: String) -> DocumentReference {
        computersCollection.document(computerId)
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
    
    // get a computer from Firestore as Computer struct
    func getComputer(computerId: String) async throws -> Computer {
        try await computerDocument(computerId: computerId).getDocument(as: Computer.self)
    }
    
    // create a new computer in Firestore from struct
    func createComputer(computer: Computer) async throws {
        // connect to Firestore and create a new document from codable struct
        try computerDocument(computerId: computer.id).setData(from: computer, merge: false)
    }
    
    // fetch computer collection onto local device
    private func getAllComputersQuery() -> Query {
        computersCollection
    }
    
    // get computers filtered by site
    private func getComputersBySiteQuery(siteId: String) -> Query {
        computersCollection
            .whereField(Computer.CodingKeys.siteId.rawValue, isEqualTo: siteId)
    }
    
    // get computers sorted by Name
    private func getAllComputersSortedByNameQuery(descending: Bool) -> Query {
        computersCollection
            .order(by: Computer.CodingKeys.name.rawValue, descending: descending)
    }
    
    // get buildings filtered by site & sorted by name
    private func getAllComputersBySiteAndNameQuery(siteId: String, descending: Bool) -> Query {
        // "The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/sitesmobile-4970/firestore/indexes?create_composite=ClJwcm9qZWN0cy9zaXRlc21vYmlsZS00OTcwL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9jb21wdXRlcnMvaW5kZXhlcy9fEAEaEgoOY29tcHV0aW5nX3NpdGUQARoRCg1jb21wdXRlcl9uYW1lEAEaDAoIX19uYW1lX18QAQ"
        computersCollection
            // filter by site
            .whereField(Computer.CodingKeys.siteId.rawValue, isEqualTo: siteId)
            // sort by name
            .order(by: Computer.CodingKeys.name.rawValue, descending: descending)
    }
    
    // get computers by name
    func getAllComputers(descending: Bool?, siteId: String?) async throws -> [Computer] {
        var query: Query = getAllComputersQuery()
        
        // if given a Site and nameSort
        if let descending, let siteId {
            // filter and sort collection
            query = getAllComputersBySiteAndNameQuery(siteId: siteId, descending: descending)
        // if given sort
        } else if let descending {
            // sort whole collection
            query = getAllComputersSortedByNameQuery(descending: descending)
        // if given filter
        } else if let siteId {
            // filter whole collection
            query = getComputersBySiteQuery(siteId: siteId)
        }
        
        print("Trying to query computers collection.")
        return try await query
            .getDocuments(as: Computer.self) // query Computers collection
    }
    
    // get count of all computers
    // we can use this to determine if we need to use pagination
    func allComputersCount() async throws -> Int {
        try await computersCollection.aggregateCount()
    }
    
    func updateComputers(_ computers: [Computer]) async throws {
        // Create a new batched write operation
        let batch = Firestore.firestore().batch()
        
        // Iterate over the computers array and update each document in the batch
        for computer in computers {
            // Get the reference to the document
            let documentRef = computerDocument(computerId: computer.id)
            
            // Encode the updated supplyCount object
            guard let data = try? encoder.encode(computer) else {
                // Handle encoding error
                throw ComputerManagerError.encodingError
            }
            
            // Set the data for the document in the batch
            batch.setData(data, forDocument: documentRef)
        }
        
        // Commit the batched write operation
        try await batch.commit()
    }
}

// Errors
enum ComputerManagerError: Error {
    case noComputerId
    case encodingError
}
