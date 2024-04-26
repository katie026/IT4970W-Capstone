//
//  AdminManager.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 3/26/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct AdminDocumentModel: Codable {
    let userId: String
    let name: String?
    
    // create DBUser manually
    init(
        userId: String,
        name: String? = nil
    ) {
        self.userId = userId
        self.name = name
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name = "name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.name, forKey: .name)
    }
}

//basic overview is its just checking if the user is in the admin collection
class AdminManager {
    static let shared = AdminManager()
    
    private init() {} // Ensure singleton pattern
    
    // get the 'admin' collection as CollectionReference
    private let adminCollection: CollectionReference = Firestore.firestore().collection("admin")
    
    // Function to check if the current user is an admin
    func checkIfCurrentUserIsAdmin(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        adminCollection.document(userId).getDocument { document, error in
            if let error = error {
                print("Error checking admin status: \(error.localizedDescription)")
                completion(false)
                return
            }
            let isAdmin = document != nil && document!.exists
            print("isAdmin: \(isAdmin)")
            completion(isAdmin)
        }
    }
    
    func checkIfUserIsAdmin(userId: String, completion: @escaping (Bool) -> Void) {
        adminCollection.document(userId).getDocument { document, error in
            if let error = error {
                print("Error checking admin status: \(error.localizedDescription)")
                completion(false)
                return
            }
            let isAdmin = document != nil && document!.exists
            print("isAdmin: \(isAdmin)")
            completion(isAdmin)
        }
    }
    
    func addUsertoAdminCollection(user: DBUser, completion: @escaping (Bool) -> Void) {
        adminCollection.document(user.id).setData([
            AdminDocumentModel.CodingKeys.userId.rawValue: user.id,
            AdminDocumentModel.CodingKeys.name.rawValue: user.fullName
        ]) { error in
            if let error = error {
                print("Error adding user \(user.id) to admin collection: \(error.localizedDescription)")
                completion(false)
                return
            }
            print("Added user \(user.id) to admin collection.")
            completion(true)
        }
    }
}
