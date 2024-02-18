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
    
//    func toggleClockInStatus() -> DBUser {
//        // get currentValue of isClockedIn, if nil return false
//        let currentValue = isClockedIn ?? false
//        return DBUser(
//            userId: userId,
//            email: email,
//            photoURL: photoURL,
//            dateCreated: dateCreated,
//            isClockedIn: !currentValue)
//    }
    
//    mutating func toggleClockInStatus() {
//        // get currentValue of isClockedIn, if nil return false
//        let currentValue = isClockedIn ?? false
//        // toggle clock in Bool
//        isClockedIn = !currentValue
//    }
    
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
    // create singleton
    static let shared = UserManager()
    private init() { }
    
    // get the users collection
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    // get user document
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
//    // create user encoder
//    private let encoder: Firestore.Encoder = {
//        let encoder = Firestore.Encoder()
//        // convert keys from camelCase to snake_case
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        return encoder
//    }()
//    
//    // create user decoder
//    private let decoder: Firestore.Decoder = {
//        let decoder = Firestore.Decoder()
//        // convert keys from snake_case to camelCase
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return decoder
//    }()
    
    // create user
    func createNewUser(user: DBUser) async throws {
        // connect to Firestore and create a new document from dictionary
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
//    func createNewUser(auth: AuthDataResultModel) async throws {
//        // create dictionary from authDataResultModel to pass into user document
//        var userData: [String:Any] = [
//            "id" : auth.uid,
//            "date_created" : Timestamp() // Timestamp is from Firebase SDK
//        ]
//        // optional values
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        if let photoURL = auth.photoURL {
//            userData["photo_url"] = photoURL
//        }
//        
//        // connect to Firestore and create a new document from dictionary
//        try await userDocument(userId: auth.uid).setData(userData, merge: false)
//    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
//    func getUser(userId: String) async throws -> DBUser {
//        let snapshot = try await userDocument(userId: userId).getDocument()
//        
//        // returns snapshot as dictionary
//        guard let data = snapshot.data(),
//              let userId = data["id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//        
//        let email = data["email"] as? String
//        let photoURL = data["photo_url"] as? String
//        let dateCreated = data["date_created"] as? Date
//        
//        return DBUser(userId: userId, email: email, photoURL: photoURL, dateCreated: dateCreated)
//    }
    
//    func updateUserClockInStatus(user: DBUser) async throws {
//        // sends a DBUser object and rewrites the user in Firestore, this could end up seding stale data though
//        try userDocument(userId: user.userId).setData(from: user, merge: true)
//    }
    
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
