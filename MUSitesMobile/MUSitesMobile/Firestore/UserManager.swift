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

struct DBUser: Codable, Identifiable, Hashable { // allow encoding and decoding
    var id: String { userId } // conform to identifiable
    let userId: String
    let studentId: Int?
    let isAnonymous: Bool?
    let hasAuthentication: Bool?
    let email: String?
    let fullName: String?
    let photoURL: String?
    let dateCreated: Date?
    var lastLogin: Date?
    let isClockedIn: Bool?
    var positionIds: [String]?
    let chairReport: ChairReport?
    
    // create DBUser manually
    init(
        userId: String,
        studentId: Int? = nil,
        isAnonymous: Bool? = nil,
        hasAuthentication: Bool? = nil,
        email: String? = nil,
        fullName: String? = nil,
        photoURL: String? = nil,
        dateCreated: Date? = nil,
        lastLogin: Date? = nil,
        isClockedIn: Bool? = nil,
        positionIds: [String]? = nil,
        chairReport: ChairReport? = nil
    ) {
        self.userId = userId
        self.studentId = studentId
        self.isAnonymous = isAnonymous
        self.hasAuthentication = hasAuthentication
        self.email = email
        self.fullName = fullName
        self.photoURL = photoURL
        self.dateCreated = dateCreated
        self.lastLogin = lastLogin
        self.isClockedIn = isClockedIn
        self.positionIds = positionIds
        self.chairReport = chairReport
    }
    
    // create DBUser from AuthDataResultModel
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.studentId = nil
        self.isAnonymous = auth.isAnonymous
        self.hasAuthentication = true
        self.email = auth.email
        self.fullName = auth.name
        self.photoURL = auth.photoURL
        self.dateCreated = Date()
        self.lastLogin = Date()
        self.isClockedIn = false
        self.positionIds = nil
        self.chairReport = nil
    }
    
    // computed property to extract the first name
    var firstName: String? {
        guard let fullName = fullName else { return nil }
        return fullName.components(separatedBy: " ").first
    }
    
    // computed property to extract the last name
    var lastName: String? {
        guard let fullName = fullName else { return nil }
        let components = fullName.components(separatedBy: " ").dropFirst()
        return components.isEmpty ? nil : components.joined(separator: " ")
    }
    
    // computed property to extract the username from email
    var pawprint: String? {
        guard let email = email else { return nil }
        let components = email.components(separatedBy: "@").first
        return components
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case studentId = "student_id"
        case isAnonymous = "is_anonymous"
        case hasAuthentication = "has_authentication"
        case email = "email"
        case fullName = "full_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case photoURL = "photo_url"
        case dateCreated = "date_created"
        case lastLogin = "last_login"
        case isClockedIn = "is_clocked_in"
        case positionIds = "positions"
        case chairReport = "chair_report"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.studentId = try container.decodeIfPresent(Int.self, forKey: .studentId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.hasAuthentication = try container.decodeIfPresent(Bool.self, forKey: .hasAuthentication)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        self.photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.lastLogin = try container.decodeIfPresent(Date.self, forKey: .lastLogin)
        self.isClockedIn = try container.decodeIfPresent(Bool.self, forKey: .isClockedIn)
        self.positionIds = try container.decodeIfPresent([String].self, forKey: .positionIds)
        self.chairReport = try container.decodeIfPresent(ChairReport.self, forKey: .chairReport)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.studentId, forKey: .studentId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.hasAuthentication, forKey: .hasAuthentication)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.fullName, forKey: .fullName)
        try container.encodeIfPresent(self.photoURL, forKey: .photoURL)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.lastLogin, forKey: .lastLogin)
        try container.encodeIfPresent(self.isClockedIn, forKey: .isClockedIn)
        try container.encodeIfPresent(self.positionIds, forKey: .positionIds)
        try container.encodeIfPresent(self.chairReport, forKey: .chairReport)
    }
    
    // conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
    
    // conforming to Equatable
    static func == (lhs: DBUser, rhs: DBUser) -> Bool {
        return lhs.userId == rhs.userId
    }
}

final class UserManager {
    // create singleton of UserManager
    static let shared = UserManager()
    private init() { }
    
    var allUsers: [DBUser] = []
    
    // get the 'users' collection as CollectionReference
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    // get user's Firestore document as DocumentReference
    public func userDocument(userId: String) -> DocumentReference {
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
    
    func createOrUpdateUser(user: DBUser) async throws {
        let userRef = Firestore.firestore().collection("users").document(user.id)
        
        let document = try await userRef.getDocument()
        if document.exists {
            try await userRef.updateData([
                DBUser.CodingKeys.lastLogin.rawValue: Timestamp(date: Date()),
            ])
        } else {
            try await createNewUser(user: user)
//            try await userRef.setData([
//                "user_id": user.id,
//                "email": user.email ?? "",
//                "date_created": Timestamp(date: Date()),
//                "last_login": Timestamp(date: Date())
//            ])
        }
    }
    
    // delete a user in Firestore
    func deleteUser(userId: String) async throws {
        try await userDocument(userId: userId).delete()
    }
    
    private func checkAuthorization(user: DBUser, completion: @escaping (Bool) -> Void) {
        if let email = user.email {
            let docRef = Firestore.firestore().collection("authenticated_emails").document(email)
            docRef.getDocument { document, error in
                if let document = document, document.exists {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func checkAuthentication(user: DBUser) async throws -> Bool {
        let docRef = userCollection.document(user.id)
        do {
            let documentSnapshot = try await docRef.getDocument()
            if let data = documentSnapshot.data(), let isAuthenticated = data[DBUser.CodingKeys.hasAuthentication.rawValue] as? Bool {
                return isAuthenticated
            } else {
                // document data or isAuthenticated value is nil
                return false
            }
        } catch {
            throw error
        }
    }
    
    // get non-authenticated DBUsers
    func getNonAuthenticatedUsers() async throws -> [DBUser] {
        let query = userCollection.whereField(DBUser.CodingKeys.hasAuthentication.rawValue, isEqualTo: false)
        
        do {
            let querySnapshot = try await query.getDocuments()
            let users: [DBUser] = try querySnapshot.documents.compactMap {
                try $0.data(as: DBUser.self)
            }
            return users
        } catch {
            throw error
        }
    }
    
    // get list of DBUsers
    func getUsersList() async throws -> [DBUser] {
        let query = userCollection
        
        return try await query
            .getDocuments(as: DBUser.self)
    }
    
    func updateAllUsers(completion: @escaping () -> Void) {
        getAllUsers() { result in
            switch result {
            case .success(let fetchedUsers):
                self.allUsers = fetchedUsers
            case .failure(let error):
                print(error.localizedDescription)
            }
            completion()
        }
    }
    
    // function to get all the users in the user collection
    func getAllUsers(completion: @escaping (Result<[DBUser], Error>) -> Void) {
        Firestore.firestore().collection("users").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let users = snapshot?.documents.compactMap { document -> DBUser? in
                try? document.data(as: DBUser.self)
            } ?? []
            
            completion(.success(users))
        }
    }
    // update user's has-auth status in Firestore
    func updateUserHasAuthentication(userId: String, hasAuthentication: Bool) async throws {
        // create dictionary to pass
        let data: [String:Any] = [
            // use DBUser object's coding key for dictionary key
            DBUser.CodingKeys.hasAuthentication.rawValue : hasAuthentication
        ]
        
        // pass dictionary and update the key:value pairs for that user
        try await userDocument(userId: userId).updateData(data)
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
    
    // add positionId to user
    func addUserPosition(userId: String, positionId: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.positionIds.rawValue : FieldValue.arrayUnion([positionId])
        ]
        
        // pass dictionary and update the key:value pairs for that user
        try await userDocument(userId: userId).updateData(data)
    }
    
    // remove positionId to user
    func removeUserPosition(userId: String, positionId: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.positionIds.rawValue : FieldValue.arrayRemove([positionId])
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
    

    func updateUserPosition(userId: String, newPosition: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        print("Firestore update initiated for user ID: \(userId) with position: \(newPosition)")
        db.collection("users").document(userId).updateData(["positions": [newPosition]]) { error in
            if let error = error {
                print("Firestore update failed for user ID: \(userId) with error: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Firestore update succeeded for user ID: \(userId) with new position: \(newPosition)")
                completion(.success(()))
            }
        }
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
