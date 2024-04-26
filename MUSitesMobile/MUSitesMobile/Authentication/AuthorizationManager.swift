//
//  AuthorizationManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/26/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct AuthorizedEmailModel: Codable {
    var id: String { email }
    let email: String
    let name: String?
    
    // create DBUser manually
    init(
        email: String,
        name: String? = nil
    ) {
        self.email = email
        self.name = name
    }
    
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case name = "name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.email = try container.decode(String.self, forKey: .email)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.email, forKey: .email)
        try container.encodeIfPresent(self.name, forKey: .name)
    }
}

//basic overview is its just checking if the user is in the authorizedEmail collection
class AuthorizationManager {
    static let shared = AuthorizationManager()
    
    private init() {} // Ensure singleton pattern
    
    // get the 'authenticated_emails' collection as CollectionReference
    private let authorizedEmailCollection: CollectionReference = Firestore.firestore().collection("authenticated_emails")
    
    func checkIfUserIsInAuthorized(email: String, completion: @escaping (Bool) -> Void) {
        authorizedEmailCollection.document(email).getDocument { document, error in
            if let error = error {
                print("Error checking authorization status: \(error.localizedDescription)")
                completion(false)
                return
            }
            let isAuthorized = document != nil && document!.exists
            print("isAuthorized: \(isAuthorized)")
            completion(isAuthorized)
        }
    }
    
    func addUserToAuthorizedEmails(user: DBUser, completion: @escaping (Error?) -> Void) {
        if let email = user.email {
            authorizedEmailCollection.document(email).setData([
                AuthorizedEmailModel.CodingKeys.email.rawValue: email,
                AuthorizedEmailModel.CodingKeys.name.rawValue: user.fullName as Any
            ]) { error in
                if let error = error {
                    print("Error adding user \(user.id) to authorizedEmail collection: \(error.localizedDescription)")
                    completion(error)
                }
                print("Added user \(user.id) to authorizedEmail collection.")
                completion(nil)
            }
        } else {
            print("Error adding user \(user.id) to authorizedEmail collection: DBUser has no email.")
            completion(AuthorizationManagerError.noEmail)
        }
    }
    
    func removeUserToAuthorizedEmails(user: DBUser, completion: @escaping (Error?) -> Void) {
        if let email = user.email {
            authorizedEmailCollection.document(email).delete() { error in
                if let error = error {
                    print("Error deleting user \(user.id) from authorizedEmail collection: \(error.localizedDescription)")
                    completion(error)
                }
                print("Deleted user \(user.id) from authorizedEmail collection.")
                completion(nil)
            }
        } else {
            print("Error deeleting user \(user.id) from authorizedEmail collection: DBUser has no email.")
            completion(AuthorizationManagerError.noEmail)
        }
    }
}

// Errors
enum AuthorizationManagerError: Error {
    case noEmail
}
