//
//  AuthenticationManager.swift
//  MUSitesMobile
//
//  Created by J Kim on 2/14/24.
//

import Foundation
import FirebaseAuth

// creating our own user model from Firebase's
struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoURL: String?
    
    init (user: User) {
        // the type "user" is from the Firebase SDK
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
    }
}

final class AuthenticationManager {
    
    // create a singleton of the class
    // a single global instance of the class; there are limitations to using this on larger apps (Dependency Injection is a better way)
    static let shared = AuthenticationManager()
    
    
    private init() { }
    
    // try to use Firebase's Auth SDK to create a user
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        // try (method can throw errors); await (asynchronously wait for the result)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
}
