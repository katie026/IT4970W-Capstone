//
//  SettingsView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/14/24.
//

import SwiftUI

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

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button("Sign Out") {
                Task { // perform an asynchronous operation
                    do {
                        // sign user out
                        try viewModel.signOut()
                        // tell RootView to display the SignInView
                        print("SIGNED OUT")
                        showSignInView = true
                    } catch {
                        // error handling here
                        print(error)
                    }
                }
            }
            // show email section if user has email auth
            if viewModel.authProviders.contains(.email) {
                emailSection // view extension below
            }
            linkAuthSection
            
        }
        .onAppear {
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            Button("Reset Password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("PASSWORD RESET EMAIL SENT")
                    } catch {
                        // error handling here
                        print(error)
                    }
                }
            }
            Button("Update Password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        // reuires a recent login
                        print("PASSWORD UPDATED")
                    } catch {
                        // error handling here
                        print(error)
                    }
                }
            }
            Button("Update Email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("EMAIL UPDATE SENT")
                    } catch {
                        // error handling here
                        print(error)
                    }
                }
            }
        } header: {
            Text("Email Functions")
        }
    }
    
    private var linkAuthSection: some View {
        Section {
            // Option to link unregistered Google account to current user
            if !viewModel.authProviders.contains(.google) {
                Button("Link Google Account") {
                    Task {
                        do {
                            try await viewModel.linkGoogleAccount()
                            print("LINKED TO GOOGLE")
                        } catch {
                            // error handling here
                            print(error)
                        }
                    }
                }
            }
            // Option to link unregistered Apple account to current user
//            if !viewModel.authProviders.contains(.apple) {
//                Button("Link Apple Account") {
//                    Task {
//                        do {
//                            try await viewModel.linkAppleAccount()
//                            // reuires a recent login
//                            print("LINKED TO APPLE")
//                        } catch {
//                            // error handling here
//                            print(error)
//                        }
//                    }
//                }
//            }
            // Option to create and link email account to current user
//            if !viewModel.authProviders.contains(.email) {
//                Button("Create & Link Email Account") {
//                    Task {
//                        do {
//                            try await viewModel.linkEmailAccount()
//                            print("LINKED TO EMAIL ACCOUNT")
//                        } catch {
//                            // error handling here
//                            print(error)
//                        }
//                    }
//                }
//            }
        } header: {
            Text("Link an account:")
        }
    }
}
