//
//  UserManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/16/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ChairReport: Codable {
    let chairType: String
    let chairCount: Int
}

struct DBUser: Codable { // allow encoding and decoding
    let userId: String
    let isAnonymous: Bool?
    let email: String?
    let photoURL: String?
    let dateCreated: Date?
    let isClockedIn: Bool?
    let positions: [String]?
    let chairReport: ChairReport?
    
    // create DBUser manually
    init(
        userId: String,
        isAnonymous: Bool? = nil,
        email: String? = nil,
        photoURL: String? = nil,
        dateCreated: Date? = nil,
        isClockedIn: Bool? = nil,
        positions: [String]? = nil,
        chairReport: ChairReport? = nil
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoURL = photoURL
        self.dateCreated = dateCreated
        self.isClockedIn = isClockedIn
        self.positions = positions
        self.chairReport = chairReport
    }
    
    // create DBUser from AuthDataResultModel
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoURL = auth.photoURL
        self.dateCreated = Date()
        self.isClockedIn = false
        self.positions = nil
        self.chairReport = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case photoURL = "photo_url"
        case dateCreated = "date_created"
        case isClockedIn = "is_clocked_in"
        case positions = "positions"
        case chairReport = "chair_report"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isClockedIn = try container.decodeIfPresent(Bool.self, forKey: .isClockedIn)
        self.positions = try container.decodeIfPresent([String].self, forKey: .positions)
        self.chairReport = try container.decodeIfPresent(ChairReport.self, forKey: .chairReport)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoURL, forKey: .photoURL)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isClockedIn, forKey: .isClockedIn)
        try container.encodeIfPresent(self.positions, forKey: .positions)
        try container.encodeIfPresent(self.chairReport, forKey: .chairReport)
    }
}

final class UserManager {
    // create singleton of UserManager
    static let shared = UserManager()
    private init() { }
    
    // get the 'users' collection as CollectionReference
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    // get user's Firestore document as DocumentReference
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    // create user encoder
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    // create user decoder
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    // get a user from Firestore as DBUser struct
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    // create a new user in Firestore
    func createNewUser(user: DBUser) async throws {
        // connect to Firestore and create a new document from codable DBUser struct
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    // update user's clock-in status in Firestore
    func updateUserClockInStatus(userId: String, isClockedIn: Bool) async throws {
        // create dictioanary to pass
        let data: [String:Any] = [
            // use DBUser object's coding key for dictionary key
            DBUser.CodingKeys.isClockedIn.rawValue : isClockedIn
        ]
        
        // pass dictionary and update the key:value pairs for that user
        try await userDocument(userId: userId).updateData(data)
    }
    
    // add position to user
    func addUserPosition(userId: String, position: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.positions.rawValue : FieldValue.arrayUnion([position])
        ]
        
        // pass dictionary and update the key:value pairs for that user
        try await userDocument(userId: userId).updateData(data)
    }
    
    // remove position to user
    func removeUserPosition(userId: String, position: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.positions.rawValue : FieldValue.arrayRemove([position])
        ]
        
        // pass dictionary and update the key:value pairs for that user
        try await userDocument(userId: userId).updateData(data)
    }
    
    // add chair report to user
    func addChairReport(userId: String, chairReport: ChairReport) async throws {
        // try to encode the ChairReport struct
        guard let data = try? encoder.encode(chairReport) else {
            throw URLError(.badURL) // cutomize this error
        }
        
        // create dictionary to pass
        let dict: [String:Any] = [
            DBUser.CodingKeys.chairReport.rawValue : data
        ]
        
        // pass dictionary and update the key:value pairs for that user
        try await userDocument(userId: userId).updateData(dict)
    }
    
    // remove chair report to user
    func removeChairReport(userId: String) async throws {
        let data: [String:Any?] = [
            DBUser.CodingKeys.chairReport.rawValue : nil
        ]
        
        // pass dictionary and update the key:value pairs for that user
        try await userDocument(userId: userId).updateData(data as [AnyHashable : Any])
    }
}
