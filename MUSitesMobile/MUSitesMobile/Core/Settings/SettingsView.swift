//
//  SettingsView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/14/24.
//

import SwiftUI

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
            // apps where user can create an account, MUST allow users to delete their account
            Button("Delete Account", role: .destructive) {
                Task {
                    do {
                        // we should warn the user first, then require them to re-sign into the account before deleting
                        // delete current user's account
                        try await viewModel.deleteCurrentUser()
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
//            linkAuthSection
            
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
            if !viewModel.authProviders.contains(.apple) {
                Button("Link Apple Account") {
                    Task {
                        do {
                            try await viewModel.linkAppleAccount()
                            // reuires a recent login
                            print("LINKED TO APPLE")
                        } catch {
                            // error handling here
                            print(error)
                        }
                    }
                }
            }
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
