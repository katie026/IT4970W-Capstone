//
//  SignInEmailView.swift
//  MUSitesMobile
//
//  Created by J Kim on 2/14/24.
//

import SwiftUI

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
        
        try await AuthenticationManager.shared.createUser(email: email, password: password)
        // the password must be 6 or more characters long or it will fail!
        // wait for the async operation to complete without blocking main thread
        // value returned was discarded
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

struct SignInEmailView: View {
    
    // create a new instance of viewModel object
    // @StateObject will keep the viewModel object alive for the lifetime of the program
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button {
                Task {
                    // first, try to sign up user
                    do {
                        try await viewModel.signUp()
                        // creates new user and signs them in
                        // now hide SignInView
                        showSignInView = false
                    } catch {
                        print("Error: \(error)")
                    }
                    
                    // if user can't sign up, try to sign them in
                    do {
                        try await viewModel.signIn()
                        // if signed in, then hide SignInView
                        showSignInView = false
                    } catch {
                        print("Error: \(error)")
                    }
                }
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In With Email")
    }
}

#Preview {
    // this view will exist in a navigation hierarchy
    NavigationStack {
        SignInEmailView(showSignInView: .constant(false))
    }
}
