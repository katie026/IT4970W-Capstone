//
//  SignInEmailViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/16/24.
//

import Foundation

@MainActor // UI updates must occur on the main thread to avoid concurrency issues
final class SignInEmailViewModel: ObservableObject {
    // to have @StateObjects vars, the class should conform to the ObservableObject protocol
    // final class means that another class will not inherit from this class; it has performance benefits
    
    // @Published means that if this value changes, send an announcement
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        // if the fields are NOT empty
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password is found.")
            // we can add validation here
            return
        }
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        // the password must be 6 or more characters long or it will fail!
        // await = wait for the async operation to complete without blocking main thread
        
        // create a DBUser from AuthDataResultModel
        let user = DBUser(auth: authDataResult)
        // create their user profile in Firestore using DBUser
        try await UserManager.shared.createNewUser(user: user)
        
    }
    
    func signIn() async throws {
        // if the fields are NOT empty
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password is found.")
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}
