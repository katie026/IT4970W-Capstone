//
//  PositionManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/25/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Position: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String?
    let nickname: String?
    let positionLevel: Int?
    let qualifiedShiftTypeIds: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case nickname = "nickname"
        case positionLevel = "position_level"
        case qualifiedShiftTypeIds = "qualified_shift_types"
    }
    
    static func == (lhs:Position, rhs: Position) -> Bool {
        // if two positions have the same ID, we're going to say they're equal to eachother
        return lhs.id == rhs.id
    }
}

class PositionManager {
    static let shared = PositionManager()
    private init() { }

    var positions: [Position] = []

    // get the collection as CollectionReference
    private let positionsCollection: CollectionReference = Firestore.firestore().collection("positions")
    
    // get Firestore document as DocumentReference
    private func positionDocument(positionId: String) -> DocumentReference {
        positionsCollection.document(positionId)
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
    
    // get a position from Firestore as position struct
    func getPosition(positionId: String) async throws -> Position {
        try await positionDocument(positionId: positionId).getDocument(as: Position.self)
    }
    
    // create a new position in Firestore from struct
    func createPosition(position: Position) async throws {
        // connect to Firestore and create a new document from codable struct
        try positionDocument(positionId: position.id).setData(from: position, merge: false)
    }
    
    // fetch positions collection onto local device
    private func getAllPositionsQuery() -> Query {
        positionsCollection
    }
    
    // get positions sorted by positionLevel
    private func getAllPositionsSortedByLevelQuery(descending: Bool) -> Query {
        positionsCollection
            .order(by: Position.CodingKeys.positionLevel.rawValue, descending: descending)
    }
    
    // update positions list
    func updatePositionsList() async throws {
        positions = try await getAllPositions(descending: false)
    }
    
    // get positions
    func getAllPositions(descending: Bool?) async throws -> [Position] {
        var query: Query = getAllPositionsQuery()
        
        // if given sort
        if let descending {
            // sort whole collection
            query = getAllPositionsSortedByLevelQuery(descending: descending)
        }
        
        print("Trying to query positions collection.")
        return try await query
            .getDocuments(as: Position.self)
    }
    
    // get count of all positions
    // we can use this to determine if we need to use pagination
    func allPositionsCount() async throws -> Int {
        try await positionsCollection.aggregateCount()
    }
}


