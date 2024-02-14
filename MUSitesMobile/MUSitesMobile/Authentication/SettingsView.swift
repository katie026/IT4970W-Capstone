//
//  SettingsView.swift
//  MUSitesMobile
//
//  Created by J Kim on 2/14/24.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
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
        let email = "kmjbcw@gmail.com"
        
        // reset current user's email (Google will send auth email first)
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "test345"
        
        // update current user's password from app
        try await AuthenticationManager.shared.updatePassword(password: password)
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
            
            emailSection // view extension below
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
}
