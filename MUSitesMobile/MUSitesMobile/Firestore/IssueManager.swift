//
//  IssueManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Issue: Identifiable, Codable, Equatable  {
    var id: String
    var description: String?
    let dateCreated: Date?
    var dateResolved: Date?
    var issueTypeId: String?
    var resolved: Bool?
    var ticket: Int?
    var reportId: String?
    var reportType: String?
    let siteId: String?
    let userSubmitted: String?
    var userAssigned: String?
    
    // create Site manually
    init(
        id: String,
        description: String? = nil,
        dateCreated: Date? = nil,
        dateResolved: Date? = nil,
        issueTypeId: String? = nil,
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
        self.dateCreated = dateCreated
        self.dateResolved = dateCreated
        self.issueTypeId = issueTypeId
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
        case dateCreated = "date_created"
        case dateResolved = "date_resolved"
        case description = "description"
        case issueTypeId = "issue_type"
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
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.dateResolved = try container.decodeIfPresent(Date.self, forKey: .dateResolved)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.issueTypeId = try container.decodeIfPresent(String.self, forKey: .issueTypeId)
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
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.dateResolved, forKey: .dateResolved)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.issueTypeId, forKey: .issueTypeId)
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

enum IssueSearchOption: String, CaseIterable, Hashable {
    case description
    case userSubmitted
    case userAssigned
    case siteName
    case issueType
    case resolutionStatus
    
    var optionLabel: String {
        switch self {
        case .description: return "Description"
        case .userSubmitted: return "Submitted by"
        case .userAssigned: return "Assigned to"
        case .siteName: return "Site"
        case .issueType: return "Type"
        case .resolutionStatus: return "Resolved"
        }
    }
}

final class IssueManager {
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
    
    // delete an issue from Firestore
    func deleteIssue(issueId: String) async throws {
        try await issueDocument(issueId: issueId).delete()
    }
    
    // fetch issue collection onto local device
    private func getAllIssuesQuery() -> Query {
        issuesCollection
    }
    
    // create new issue document in Firestore, return id
    func getNewIssueId() async throws -> String {
        // create auto-generated document in collection
        let document = issuesCollection.document()
        // get document id
        return document.documentID
    }
    
    // get issues sorted by Date
    private func getIssuesSortedByDateQuery(descending: Bool) -> Query {
        issuesCollection
            .order(by: Issue.CodingKeys.dateCreated.rawValue, descending: descending)
    }
    
    // get issues filtered by date range
    private func getIssuesByDateQuery(startDate: Date, endDate: Date) -> Query {
        issuesCollection
            .whereField(Issue.CodingKeys.dateCreated.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(Issue.CodingKeys.dateCreated.rawValue, isLessThanOrEqualTo: endDate)
    }
    
    // get issues filtered by date & sorted by date
    private func getIssuesSortedFilteredByDateQuery(descending: Bool, startDate: Date, endDate: Date) -> Query {
        issuesCollection
            // filter by date
            .whereField(Issue.CodingKeys.dateCreated.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(Issue.CodingKeys.dateCreated.rawValue, isLessThanOrEqualTo: endDate)
            // sort by date
            .order(by: Issue.CodingKeys.dateCreated.rawValue, descending: descending)
    }
    
    // get issues sorted by typeId
    private func getAllIssuesSortedByNameQuery(descending: Bool) -> Query {
        issuesCollection
            .order(by: Issue.CodingKeys.issueTypeId.rawValue, descending: descending)
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
    
    // get issues filtered by userAssigned & sorted by date
    func getUserIssues(userId: String) async throws -> [Issue] {
        let query = issuesCollection
            // filter by user
            .whereField(Issue.CodingKeys.userAssigned.rawValue, isEqualTo: userId)
        return try await query
            .getDocuments(as: Issue.self)
    }
    
    // get count of all issues
    // we can use this to determine if we need to use pagination
    func allIssuesCount() async throws -> Int {
        try await issuesCollection.aggregateCount()
    }
    
    func toggleIssueResolution(issue: Issue) async throws {
        var issue = issue
        
        // if issue is resolved (if .resolved is nil, assume it's not resolved
        if issue.resolved ?? false {
            // mark issue as unresolved
            issue.resolved = false
            // erase dateResolved
            issue.dateResolved = nil
        // if issue is not resolved
        } else {
            // mark issue as resolved
            issue.resolved = true
            // update dateResolved
            issue.dateResolved = Date()
        }
        
        // update issue in Firestore
        try await updateIssue(issue)
    }
    
    func updateUserAssigned(issue: Issue, userId: String?) async throws {
        var issue = issue
        
        if userId != nil && userId != "" {
            issue.userAssigned = userId
        } else {
            issue.userAssigned = nil
        }
        
        // update issue in Firestore
        try await updateIssue(issue)
    }
    
    func updateIssue(_ issue: Issue) async throws {
        // Get the reference to the document
        let documentRef = issueDocument(issueId: issue.id)
        
        // Encode the updated SiteCapatin object
        guard let data = try? encoder.encode(issue) else {
            // Handle encoding error
            throw IssueManagerError.encodingError
        }
            
        // Set the data for the document
        try await documentRef.setData(data)
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
    
    // Delete a batch of issues from Firestore
    func deleteIssues(issueIds: [String]) async throws {
        // Create a new batched write operation
        let batch = Firestore.firestore().batch()
        
        // Iterate over the issue IDs array and delete each document in the batch
        for issueId in issueIds {
            // Get the reference to the document
            let documentRef = issueDocument(issueId: issueId)
            
            // Delete the document in the batch
            batch.deleteDocument(documentRef)
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
