//
//  AuthenticationViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/16/24.
//

import Foundation
import Firebase

@MainActor
final class AuthenticationViewModel: ObservableObject {
    // ObservableObject protocol allows models to publish changes to their properties using the @Published and trigger reactive UI updates
    
    // Sign in with Google
//    func signInGoogle() async throws -> Bool {
//        // create a SignInGoogleHelper
//        let helper = SignInGoogleHelper()
//        // get Google Sign In result model from Google using SignInGoogleHelper
//        let googleSignInResult = try await helper.signIn()
//        //TODO: Filter for emails here(just umsystem.edu emails)
//        if let email = googleSignInResult.email {
//            if email.hasSuffix("@umsystem.edu") {
//                // try to log into Firebase using Google result (holds the tokens)
//                let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(googleSignInResult: googleSignInResult)
//                // create a DBUser from AuthDataResultModel
//                let user = DBUser(auth: authDataResult)
//                // create their user profile in Firestore using DBUser
//                try await UserManager.shared.createNewUser(user: user)
//                return true
//            } else {
//                return false
//            }
//        } else {
//            return false
//        }
//    }
    func signInGoogle() async throws -> Bool {
        // create a SignInGoogleHelper
        let helper = SignInGoogleHelper()
        // get Google Sign In result model from Google using SignInGoogleHelper
        let googleSignInResult = try await helper.signIn()
        // Filter for emails here(just umsystem.edu emails)
        if let email = googleSignInResult.email {
            if email.hasSuffix("@umsystem.edu") {
                // Check if the email is in the authenticated_emails collection
                let document = try await Firestore.firestore().collection("authenticated_emails").document(email).getDocument()
                // try to log into Firebase using Google result (holds the tokens)
                let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(googleSignInResult: googleSignInResult)
                // create a DBUser from AuthDataResultModel
                let user = DBUser(auth: authDataResult)
                // create their user profile in Firestore using DBUser
                try await UserManager.shared.createNewUser(user: user)
                
                if document.exists {
                    return true
                } else {
                    // Email is valid but not authenticated
                    throw NSError(domain: "Authentication", code: 401, userInfo: [NSLocalizedDescriptionKey: "Your email address is not authorized for access. Please contact support if you believe this is an error."])
                }
            } else {
                // Invalid email domain
                throw NSError(domain: "Authentication", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid email domain. Only umsystem.edu email addresses are allowed."])
            }
        } else {
            // Email is not provided in the Google sign-in result
            throw NSError(domain: "Authentication", code: 402, userInfo: [NSLocalizedDescriptionKey: "No email found in your Google account info. Please ensure your Google account includes an email address."])
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
