//
//  IssueManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Issue: Identifiable, Codable, Equatable {
<<<<<<< HEAD
    let id: String
    var description: String?  // Change this from 'let' to 'var' to make it mutable
    let timestamp: Date?
    var issueType: String?
    let resolved: Bool?
=======
    var id: String
    var description: String?
    let timestamp: Date?
    var issueType: String?
    var resolved: Bool?
>>>>>>> hourly-cleaning
    var ticket: Int?
    let reportId: String?
    var reportType: String?
    let siteId: String?
    let userSubmitted: String?
    var userAssigned: String?
<<<<<<< HEAD


=======
    
>>>>>>> hourly-cleaning
    // create Site manually
    init(
        id: String,
        description: String? = nil,
        timestamp: Date? = nil,
        issueType: String? = nil,
        resolved: Bool? = nil,
        ticket: Int? = nil,
        reportId: String? = nil,
        reportType: String? = nil,
        siteId: String? = nil,
        userSubmitted: String? = nil,
        userAssigned: String? = nil
    ) {
        self.id = id
        self.description = description
        self.timestamp = timestamp
        self.issueType = issueType
        self.resolved = resolved
        self.ticket = ticket
        self.reportId = reportId
        self.reportType = reportType
        self.siteId = siteId
        self.userSubmitted = userSubmitted
        self.userAssigned = userAssigned
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case timestamp = "timestamp"
        case description = "description"
        case issueType = "issue_type"
        case resolved = "resolved"
        case ticket = "ticket"
        case reportId = "report_id"
        case reportType = "report_type"
        case siteId = "site"
        case userSubmitted = "user_submitted"
        case userAssigned = "user_assigned"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.issueType = try container.decodeIfPresent(String.self, forKey: .issueType)
        self.resolved = try container.decodeIfPresent(Bool.self, forKey: .resolved)
        self.ticket = try container.decodeIfPresent(Int.self, forKey: .ticket)
        self.reportId = try container.decodeIfPresent(String.self, forKey: .reportId)
        self.reportType = try container.decodeIfPresent(String.self, forKey: .reportType)
        self.siteId = try container.decodeIfPresent(String.self, forKey: .siteId)
        self.userSubmitted = try container.decodeIfPresent(String.self, forKey: .userSubmitted)
        self.userAssigned = try container.decodeIfPresent(String.self, forKey: .userAssigned)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.timestamp, forKey: .timestamp)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.issueType, forKey: .issueType)
        try container.encodeIfPresent(self.resolved, forKey: .resolved)
        try container.encodeIfPresent(self.ticket, forKey: .ticket)
        try container.encodeIfPresent(self.reportId, forKey: .reportId)
        try container.encodeIfPresent(self.reportType, forKey: .reportType)
        try container.encodeIfPresent(self.siteId, forKey: .siteId)
        try container.encodeIfPresent(self.userSubmitted, forKey: .userSubmitted)
        try container.encodeIfPresent(self.userAssigned, forKey: .userAssigned)
    }
    
    static func == (lhs:Issue, rhs: Issue) -> Bool {
        // if two issues have the same ID, we're going to say they're equal to eachother
        return lhs.id == rhs.id
    }
}

final class IssueManager {
<<<<<<< HEAD
    // Singleton instance
    static let shared = IssueManager()
    private init() {}

    // Reference to the Firestore collection
    private let issuesCollection: CollectionReference = Firestore.firestore().collection("reported_issues")

    // Method to get a Firestore document reference safely
    private func issueDocument(issueId: String) -> DocumentReference? {
        guard !issueId.isEmpty else {
            print("Error: Document path cannot be empty.")
            return nil
        }
        return issuesCollection.document(issueId)
    }

    // Method to retrieve an issue from Firestore
    func getIssue(issueId: String) async throws -> Issue {
        guard let document = issueDocument(issueId: issueId) else {
            throw IssueManagerError.invalidDocumentPath
        }
        return try await document.getDocument(as: Issue.self)
    }

    // Method to create a new issue in Firestore
    func createIssue(issue: Issue) async throws {
        guard let document = issueDocument(issueId: issue.id) else {
            throw IssueManagerError.invalidDocumentPath
        }
        try await document.setData(from: issue, merge: false)
    }

    // Query method for retrieving all issues
    private func getAllIssuesQuery() -> Query {
        issuesCollection
    }

    // Method to sort and filter issues by date
    private func getIssuesSortedFilteredByDateQuery(descending: Bool, startDate: Date, endDate: Date) -> Query {
        issuesCollection
            .whereField(Issue.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(Issue.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
            .order(by: Issue.CodingKeys.timestamp.rawValue, descending: descending)
    }

    // Method to retrieve all issues based on sorting and filtering criteria
    func getAllIssues(descending: Bool?, startDate: Date?, endDate: Date?) async throws -> [Issue] {
        var query: Query = getAllIssuesQuery()
        if let descending = descending, let startDate = startDate, let endDate = endDate {
            query = getIssuesSortedFilteredByDateQuery(descending: descending, startDate: startDate, endDate: endDate)
        } else if let startDate = startDate, let endDate = endDate {
            query = issuesCollection
                .whereField(Issue.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
                .whereField(Issue.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
        } else if let descending = descending {
            query = issuesCollection
                .order(by: Issue.CodingKeys.timestamp.rawValue, descending: descending)
        }
        print("Querying issues collection.")
        return try await query.getDocuments(as: Issue.self)
    }

    // Batch update method for issues
    func updateIssues(_ issues: [Issue]) async throws {
        let batch = Firestore.firestore().batch()
        for issue in issues {
            guard let document = issueDocument(issueId: issue.id), !issue.id.isEmpty else {
                throw IssueManagerError.invalidDocumentPath
            }
            let data = try Firestore.Encoder().encode(issue)
            batch.setData(data, forDocument: document)
        }
        try await batch.commit()
    }

    // Error enum for IssueManager-specific errors
    enum IssueManagerError: Error {
        case noIssueId
        case encodingError
        case invalidDocumentPath
    }
}


enum IssueManagerError: Error {
    case noIssueId
    case encodingError
    case invalidDocumentPath
}

=======
    // create singleton of manager
    static let shared = IssueManager()
    private init() { }
    
    // get the collection as CollectionReference
    private let issuesCollection: CollectionReference = Firestore.firestore().collection("reported_issues")
    
    // get Firestore document as DocumentReference
    private func issueDocument(issueId: String) -> DocumentReference {
        issuesCollection.document(issueId)
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
    
    // get a issue from Firestore as Issue struct
    func getIssue(issueId: String) async throws -> Issue {
        try await issueDocument(issueId: issueId).getDocument(as: Issue.self)
    }
    
    // create a new issue in Firestore from struct
    func createIssue(issue: Issue) async throws {
        // connect to Firestore and create a new document from codable struct
        try issueDocument(issueId: issue.id).setData(from: issue, merge: false)
    }
    
    // fetch issue collection onto local device
    private func getAllIssuesQuery() -> Query {
        issuesCollection
    }
    
    // get hourlyCleanings sorted by Date
    private func getIssuesSortedByDateQuery(descending: Bool) -> Query {
        issuesCollection
            .order(by: Issue.CodingKeys.timestamp.rawValue, descending: descending)
    }
    
    // get issues filtered by date range
    private func getIssuesByDateQuery(startDate: Date, endDate: Date) -> Query {
        issuesCollection
            .whereField(Issue.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(Issue.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
    }
    
    // get issues filtered by date & sorted by date
    private func getIssuesSortedFilteredByDateQuery(descending: Bool, startDate: Date, endDate: Date) -> Query {
        issuesCollection
            // filter by date
            .whereField(Issue.CodingKeys.timestamp.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(Issue.CodingKeys.timestamp.rawValue, isLessThanOrEqualTo: endDate)
            // sort by date
            .order(by: Issue.CodingKeys.timestamp.rawValue, descending: descending)
    }
    
    // get issues sorted by date
    private func getAllIssuesSortedByNameQuery(descending: Bool) -> Query {
        issuesCollection
            .order(by: Issue.CodingKeys.timestamp.rawValue, descending: descending)
    }
    
    // get issues by name
    func getAllIssues(descending: Bool?, startDate: Date?, endDate: Date?) async throws -> [Issue] {
        var query: Query = getAllIssuesQuery()
        
        // if given a Site and nameSort
        if let descending, let startDate, let endDate {
            // filter and sort collection
            query = getIssuesSortedFilteredByDateQuery(descending: descending, startDate: startDate, endDate: endDate)
        // if just given sort
        } else if let descending {
            // sort whole collection
            query = getIssuesSortedByDateQuery(descending: descending)
        // if just given filter
        } else if let startDate, let endDate {
            // filter whole collection
            query = getIssuesByDateQuery(startDate: startDate, endDate: endDate)
        }
        
        print("Trying to query issues collection.")
        return try await query
            .getDocuments(as: Issue.self) // query Issues collection
    }
    
    // get count of all issues
    // we can use this to determine if we need to use pagination
    func allIssuesCount() async throws -> Int {
        try await issuesCollection.aggregateCount()
    }
    
    func updateIssues(_ issues: [Issue]) async throws {
        // Create a new batched write operation
        let batch = Firestore.firestore().batch()
        
        // Iterate over the issues array and update each document in the batch
        for issue in issues {
            // Get the reference to the document
            let documentRef = issueDocument(issueId: issue.id)
            
            // Encode the updated supplyCount object
            guard let data = try? encoder.encode(issue) else {
                // Handle encoding error
                throw IssueManagerError.encodingError
            }
            
            // Set the data for the document in the batch
            batch.setData(data, forDocument: documentRef)
        }
        
        // Commit the batched write operation
        try await batch.commit()
    }
}

// Errors
enum IssueManagerError: Error {
    case noIssueId
    case encodingError
}
>>>>>>> hourly-cleaning
