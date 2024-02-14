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
    
    // check local SDK if user is authenticated (signed in)
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        // use Firebase SDK to check if there is a current authenticated user
        // func is NOT async, because it is not reaching out to the server, it is checking the SDK locally
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
            // if no authenticated user in our app, user = nil
        }
        
        // return ResultModel if user is authenticated
        return AuthDataResultModel(user: user)
    }
    
    // try to use Firebase's Auth SDK to create a user
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        // try (method can throw errors); await (asynchronously wait for the result)
        
        // return the ResultModel of newly created user, saved in the local SDK
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // sign out locally (does not ping the server)
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
}
