//
//  SettingsViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/16/24.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func deleteCurrentUser() async throws {
        try await AuthenticationManager.shared.deleteCurrentUser()
    }
    
    func resetPassword() async throws {
        // get current user email
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist) // should customize this error
        }
        
        // reset current user's password (by sending email)
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "kmjbcw@gmail.com" // create UI to get this from user
        
        // reset current user's email (Google will send auth email first)
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "test345" // create UI to get this from user
        
        // update current user's password from app
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        let googleSignInResult = try await helper.signIn()
        self.authUser = try await AuthenticationManager.shared.linkGoogle(googleSignInResult: googleSignInResult)
    }
    
    // unkown if this works yet
    func linkAppleAccount() async throws {
        let helper = SignInAppleHelper()
        for try await appleSignInResult in helper.startSignInWithAppleFlow() {
            self.authUser = try await AuthenticationManager.shared.signInWithApple(appleSignInResult: appleSignInResult)
            break
        }
    }
    
    func linkEmailAccount() async throws {
        let email = "hi@testing.com"
        let password = "test123"
        self.authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
    }
}
