//
//  UserManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/16/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

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
    
    // create a var to hold UserBuilding listener
    private var userBuildingsListener : ListenerRegistration? = nil
    
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
        // create dictionary to pass
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
    
    // MARK: BOOTCAMP #15 TUTORIAL: sub-collections
    private func userBuildingsCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("user_buildings")
    }
    
    private func userBuildingDocument(userId: String, userBuildingId: String) -> DocumentReference {
        userBuildingsCollection(userId: userId).document(userBuildingId)
    }
    
    func addUserBuilding(userId: String, buildingId: String) async throws {
        // create auto-generated document in sub-collection
        let document = userBuildingsCollection(userId: userId).document()
        // get document id
        let documentId = document.documentID
        
        // create dictionary to push
        let data: [String:Any] = [
            UserBuilding.CodingKeys.id.rawValue : documentId,
            UserBuilding.CodingKeys.buildingId.rawValue : buildingId,
            UserBuilding.CodingKeys.dateAssigned.rawValue : Timestamp()
        ]
        
        // set data to new document (this does allow multiple of the same uilding be added to a single user)
        try await document.setData(data, merge: false)
    }
    
    func removeUserBuilding(userId: String, userBuildingId: String) async throws {
        try await userBuildingDocument(userId: userId, userBuildingId: userBuildingId).delete()
    }
    
    func getAllUserBuildings(userId: String) async throws -> [UserBuilding] {
        return try await userBuildingsCollection(userId: userId).getDocuments(as: UserBuilding.self)
    }
    
    func removeListenerForAllUserBuildings() {
        self.userBuildingsListener?.remove()
    }
    
    func addListenerForAllUserBuildings(userId: String, completion: @escaping (_ buildings: [UserBuilding]) -> Void) {
        // add listner
        self.userBuildingsListener = userBuildingsCollection(userId: userId).addSnapshotListener { querySnapshot, error in
            // this closure will continuouslly execute over time for the rest of its lifespan, any time there is a change at this collection, this snapshot listener will execute
            // needs @escaping because the completion handler will be outliving the original call for addListenerForAllUserBuildings() function
            
            // get snapshot of all userBuildings as documents fot a user
            guard let documents = querySnapshot?.documents else {
                print("No Documents")
                return
            }
            
            // convert documents to Buildings
//            // compactMap means if any do not convert, we just ignore and move on
//            let buildings: [UserBuilding] = documents.compactMap { documentSnapshot in
//                return try? documentSnapshot.data(as: UserBuilding.self)
//                // try? makes it optinoal meaning compact map will remove it from the array if nil
//            }
            
            // decode the snapshot's documents into an array of UserBuildings
            let buildings: [UserBuilding] = documents.compactMap({ try? $0.data(as: UserBuilding.self) })
            // completion handler gets called on the "way back"
            completion(buildings)
            
            // be notified on what is changing
            querySnapshot?.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("New user_building: \(diff.document.data())")
                }
                if (diff.type == .modified) {
                    print("Modified user_building: \(diff.document.data())")
                }
                if (diff.type == .removed) {
                    print("Removed user_building: \(diff.document.data())")
                }
            }
        }
    }
    
    // use combine to convert the listener into a Publisher
//    func addListenerForAllUserBuildings(userId: String) -> AnyPublisher<[UserBuilding], Error> {
//        // create a publisher
//        let publisher = PassthroughSubject<[UserBuilding], Error>() // [UserBuilding] will be published back to this app
//        // CurrentValueSubject is a publisher that will produce values over time and has a value at the current state
//            // PassthroughSubject is a publisher that does not have a starting value and only publishes through the publisher
//        
//        // execute a Query snapshot listener, closure is async and will return at a later point in time
//        self.userBuildingsListener = userBuildingsCollection(userId: userId).addSnapshotListener { querySnapshot, error in
//            // this closure will continuouslly execute over time for the rest of its lifespan, any time there is a change at this collection, this snapshot listener will execute
//            // needs @escaping because the completion handler will be outliving the original call for addListenerForAllUserBuildings() function
//            
//            // get snapshot of all userBuildings as documents fot a user
//            guard let documents = querySnapshot?.documents else {
//                print("No Documents")
//                return
//            }
//            
//            // decode the snapshot's documents into an array of UserBuildings
//            let buildings: [UserBuilding] = documents.compactMap({ try? $0.data(as: UserBuilding.self) })
//            
//            // instead of calling completion handler, access the Publisher above and send an input [UserBuilding] into it
//            publisher.send(buildings)
//        }
//        
//        // return publisher back to app immediately, so the view can simply listen to the publisher
//        return publisher.eraseToAnyPublisher()
//    }
    
    func addListenerForAllUserBuildings(userId: String) -> AnyPublisher<[UserBuilding], Error> {
        // create a publisher
        let (publisher, listener) = userBuildingsCollection(userId: userId)
            .addSnapshotListener(as: UserBuilding.self)
        
        self.userBuildingsListener = listener
        return publisher
    }
}

struct UserBuilding: Codable {
    let id: String
    let buildingId: String
    let dateAssigned: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case buildingId = "building_id"
        case dateAssigned = "date_assigned"
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<UserBuilding.CodingKeys> = try decoder.container(keyedBy: UserBuilding.CodingKeys.self)
        self.id = try container.decode(String.self, forKey: UserBuilding.CodingKeys.id)
        self.buildingId = try container.decode(String.self, forKey: UserBuilding.CodingKeys.buildingId)
        self.dateAssigned = try container.decode(Date.self, forKey: UserBuilding.CodingKeys.dateAssigned)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: UserBuilding.CodingKeys.self)
        try container.encode(self.id, forKey: UserBuilding.CodingKeys.id)
        try container.encode(self.buildingId, forKey: UserBuilding.CodingKeys.buildingId)
        try container.encode(self.dateAssigned, forKey: UserBuilding.CodingKeys.dateAssigned)
    }
}
