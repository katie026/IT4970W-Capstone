//
//  AuthenticationViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/16/24.
//

import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    // ObservableObject protocol allows models to publish changes to their properties using the @Published and trigger reactive UI updates
    
    // Sign in with Google
    func signInGoogle() async throws -> Bool {
        // create a SignInGoogleHelper
        let helper = SignInGoogleHelper()
        // get Google Sign In result model from Google using SignInGoogleHelper
        let googleSignInResult = try await helper.signIn()
        //TODO: Filter for emails here(just umsystem.edu emails)
        if let email = googleSignInResult.email {
            if email.hasSuffix("@umsystem.edu") {
                // try to log into Firebase using Google result (holds the tokens)
                let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(googleSignInResult: googleSignInResult)
                // create a DBUser from AuthDataResultModel
                let user = DBUser(auth: authDataResult)
                // create their user profile in Firestore using DBUser
                try await UserManager.shared.createNewUser(user: user)
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    // Sign in with Apple (will not work until we have developer account)
    func signInApple() async throws {
        // async means signInApple() does not complete until all these lines are completed as well, meaning helper will not get deallocated as we wait for the sign in to complete
        
        // create a SignInAppleHelper
        let helper = SignInAppleHelper()
        
        // Use a for-await loop to handle the asynchronous stream
        for try await appleSignInResult in helper.startSignInWithAppleFlow() {
            // Try to sign in to Firebase using Apple credentials
            let authDataResult = try await AuthenticationManager.shared.signInWithApple(appleSignInResult: appleSignInResult)
            // create a DBUser from AuthDataResultModel
            let user = DBUser(auth: authDataResult)
            // create their user profile in Firestore using DBUser
            try await UserManager.shared.createNewUser(user: user)
            // If successful, you can break out of the loop as you have the result
            break
        }
    }
    
    // Sign in Anonymously
    func signInAnonymous() async throws {
        // sign in user anonymously and return authDataResult
        let authDataResult = try await AuthenticationManager.shared.signInAnonymous()
        // create a DBUser from AuthDataResultModel
        let user = DBUser(auth: authDataResult)
        // create their user profile in Firestore using DBUser
        try await UserManager.shared.createNewUser(user: user)
    }
}
