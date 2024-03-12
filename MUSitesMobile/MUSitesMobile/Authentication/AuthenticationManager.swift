//
//  AuthenticationManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/14/24.
//

import Foundation
import FirebaseAuth

// creating our own user model from Firebase's User model
struct AuthDataResultModel {
    let uid: String
    let email: String?
    let name: String?
    let photoURL: String?
    let isAnonymous: Bool?
    
    init (user: User) {
        // the type "User" is from the Firebase SDK
        self.uid = user.uid
        self.email = user.email
        self.name = user.displayName
        self.photoURL = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
}

// creating an enum for expected authentication providers
enum AuthProviderOption: String {
    // these strings are how Firebase returns auth providers
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    // create a singleton of the class
    // a single global instance of the class; there are limitations to using this on larger apps (Dependency Injection is a better way)
    static let shared = AuthenticationManager()
    private init() { }
    
    // check if user signed in (using local SDK)
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
    
    // get list of auth providers for user (enums)
    func getProviders() throws -> [AuthProviderOption] {
        // get authentication provider data for current user
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        } // providerData will return as an array because users can sign in with multiple providers
        
        // create list of providers
        var providers: [AuthProviderOption] = []
        
        // check all providers under the current user
        for provider in providerData {
            // create a providerOption (enum) from the provider ID
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                // add to providers list
                providers.append(option)
                // continue loop if this fails
            } else {
                // crash the app if a new Auth is added and the Option (enum) could not be created because it was not added yet
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        
        return providers
    }
    
    // sign out user locally (does not ping the server)
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // delete current user
    func deleteCurrentUser() async throws {
        // get current user
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        // update user document's auth status
        try await UserManager.shared.updateUserHasAuthentication(userId: user.uid, hasAuthentication: false)
        
        // delete user auth
        try await user.delete()
    }
}

// MARK: SIGN IN EMAIL
extension AuthenticationManager {
    // create user (using Firebase's Auth SDK)
    @discardableResult // tells Swift it's okay if we do not use the result that will be returned
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        // try (method can throw errors); await (asynchronously wait for the result)
        
        // return custom ResultModel of newly created user, saved in the local SDK
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // sign user in with email
    @discardableResult
    func signInEmail(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // reset password (ping server)
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
        // if it doesn't throw error, it was successful
        // Google will send a password reset email for us! User will reset using web browser.
    }
    
    // update password (ping server)
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    // update email (ping server)
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
}

// MARK: SIGN IN SSO
extension AuthenticationManager {
    
    // sign into Firebase using AuthCredential object
    func signInWithCredential(credential: AuthCredential) async throws -> AuthDataResultModel {
        // send AuthCredential to Firebase and receive an AuthDataResult
        let authDataResult = try await Auth.auth().signIn(with: credential)
        // get user from AuthDataResult and return an AuthDataResultModel
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // sign in using Google
    @discardableResult
    func signInWithGoogle(googleSignInResult: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        // use FirebaseAuth SDK to create Firebase AuthCredential using Google tokens
        let credential = GoogleAuthProvider.credential(withIDToken: googleSignInResult.idToken, accessToken: googleSignInResult.accessToken)
        // sign into Firebase using Firebase AuthCredential
        return try await signInWithCredential(credential: credential)
    }
    
    // sign in using Apple
        // signing in with Apple will require an Apple Developer account for it to work
        // an option to sign in with Apple will be required to be published in the App Store
    @discardableResult
    func signInWithApple(appleSignInResult: AppleSignInResultModel) async throws -> AuthDataResultModel {
        // use FirebaseAuth SDK to create Firebase AuthCredential using AppleIDCredential, nonce, and ID token
        let credential = OAuthProvider.appleCredential(withIDToken: appleSignInResult.idToken, rawNonce: appleSignInResult.nonce, fullName: appleSignInResult.fullNameComponents)
        // sign into Firebase using Firebase AuthCredential
        return try await signInWithCredential(credential: credential)
    }
}

// MARK: SIGN IN ANONYMOUS
extension AuthenticationManager {
    @discardableResult
    func signInAnonymous() async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
}

// MARK: LINK SIGN-INS
extension AuthenticationManager {
    // NOTE: only Google/Apple/Email accounts NOT ALREADY associated with a user may be linked to the current user
    
    // link current user to another auth provider using AuthCredential
    private func linkCredential(credential: AuthCredential) async throws -> AuthDataResultModel {
        // get current user
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        // send AuthCredential to Firebase and attempt to link new credentials to current user
        let authDataResult = try await user.link(with: credential)
        // get user from AuthDataResult and return an AuthDataResultModel
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // link Google account to current user
    func linkGoogle(googleSignInResult: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        // use FirebaseAuth SDK to create Firebase AuthCredential using Google tokens
        let credential = GoogleAuthProvider.credential(withIDToken: googleSignInResult.idToken, accessToken: googleSignInResult.accessToken)
        // link current user to Google provider using AuthCredential
        return try await linkCredential(credential: credential)
    }
    
    // link Apple account to current user
    func linkApple(appleSignInResult: AppleSignInResultModel) async throws -> AuthDataResultModel {
        // use FirebaseAuth SDK to create Firebase AuthCredential using AppleIDCredential, nonce, and ID token
        let credential = OAuthProvider.appleCredential(withIDToken: appleSignInResult.idToken, rawNonce: appleSignInResult.nonce, fullName: appleSignInResult.fullNameComponents)
        // link current user to Apple provider using AuthCredential
        return try await linkCredential(credential: credential)
    }
    
    // link existing Email account to current user
    func linkEmail(email: String, password: String) async throws -> AuthDataResultModel {
        // use FirebaseAuth SDK to create Firebase AuthCredential using email and password
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        // link current user to Firebase using AuthCredential
        return try await linkCredential(credential: credential)
    }
}
