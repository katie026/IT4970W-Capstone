//
//  SignInEmailView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/14/24.
//

import SwiftUI

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
