//
//  UserManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/16/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser: Codable { // allow encoding and decoding
    let userId: String
    let email: String?
    let photoURL: String?
    let dateCreated: Date?
    let isClockedIn: Bool?
    
    // create DBUser manually
    init(
        userId: String,
        email: String? = nil,
        photoURL: String? = nil,
        dateCreated: Date? = nil,
        isClockedIn: Bool? = nil
    ) {
        self.userId = userId
        self.email = email
        self.photoURL = photoURL
        self.dateCreated = dateCreated
        self.isClockedIn = isClockedIn
    }
    
    // create DBUser from AuthDataResultModel
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoURL = auth.photoURL
        self.dateCreated = Date()
        self.isClockedIn = false
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case photoURL = "photo_url"
        case dateCreated = "date_created"
        case isClockedIn = "is_clocked_in"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isClockedIn = try container.decodeIfPresent(Bool.self, forKey: .isClockedIn)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoURL, forKey: .photoURL)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isClockedIn, forKey: .isClockedIn)
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
}
