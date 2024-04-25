//
//  IssueTypeManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct IssueType: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case notes = "notes"
    }
}

class IssueTypeManager {
    static let shared = IssueTypeManager()
    private init() { }

    @Published var issueTypes: [IssueType] = []

    // get the collection as CollectionReference
    private let issueTypesCollection: CollectionReference = Firestore.firestore().collection("issue_types")
    
    // get Firestore document as DocumentReference
    private func issueTypeDocument(issueTypeId: String) -> DocumentReference {
        issueTypesCollection.document(issueTypeId)
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
    
    // get an issue type from Firestore as issueSite struct
    func getIssueType(issueTypeId: String) async throws -> IssueType {
        try await issueTypeDocument(issueTypeId: issueTypeId).getDocument(as: IssueType.self)
    }
    
    // create a new issue type in Firestore from struct
    func createIssueType(issueType: IssueType) async throws {
        // connect to Firestore and create a new document from codable struct
        try issueTypeDocument(issueTypeId: issueType.id).setData(from: issueType, merge: false)
    }
    
    // fetch issue types collection onto local device
    private func getAllIssueTypesQuery() -> Query {
        issueTypesCollection
    }
    
    // get issue types sorted by Name
    private func getAllIssueTypesSortedByNameQuery(descending: Bool) -> Query {
        issueTypesCollection
            .order(by: IssueType.CodingKeys.name.rawValue, descending: descending)
    }
    
    // get issue types by name
    func getAllIssueTypes(descending: Bool?) async throws -> [IssueType] {
        let query: Query = getAllIssueTypesQuery()
        
//        // if given sort
//        if let descending {
//            // sort whole collection
//            query = getAllSitesSortedByNameQuery(descending: descending)
//        }
        print("Trying to query issue_types collection.")
        return try await query
            .getDocuments(as: IssueType.self) // query issue_types collection
    }
    
    // get count of all sites
    // we can use this to determine if we need to use pagination
    func allIssueTypesCount() async throws -> Int {
        try await issueTypesCollection.aggregateCount()
    }
    
    func fetchIssueTypes() {
        Task {
            do {
                issueTypes = try await getAllIssueTypes(descending: false)
            } catch {
                print("Error fetching issue types: \(error)")
            }
        }
    }
}
