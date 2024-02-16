//
//  AuthenticationView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/14/24.
//

import SwiftUI
import GoogleSignIn // can remove this if we use out own Google Button
import GoogleSignInSwift // can remove this if we use out own Google Button

// Authentication View Model to hold functions
@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    func signInGoogle() async throws {
        // create a SignInGoogleHelper
        let helper = SignInGoogleHelper()
        // get Google Sign In result model from Google using SignInGoogleHelper
        let googleSignInResult = try await helper.signIn()
        // now try to log into Firebase using Google result (holds the tokens)
        try await AuthenticationManager.shared.signInWithGoogle(GoogleSignInResult: googleSignInResult)
    }
}

struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign In with Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
                Task {
                    do {
                        // try to sign in using Google
                        try await viewModel.signInGoogle()
                        // turn off the SignInView
                        showSignInView = false;
                    } catch {
                        print(error)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
    }
}
