//
//  AuthenticationView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/14/24.
//

import SwiftUI
import GoogleSignIn // can remove this if we use out own Google Button
import GoogleSignInSwift // can remove this if we use out own Google Button

struct AuthenticationView: View {
    // create a view model to hold functions
    @StateObject private var viewModel = AuthenticationViewModel()
    // recieve and link to the showSignInView variable that belongs to RootView
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            // Sign in Anonymously
            Button (action: {
                Task {
                    do {
                        // try to sign in Anonymously
                        try await viewModel.signInAnonymous()
                        // turn off the SignInView
                        showSignInView = false;
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Sign In Anonymously")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
            })
            
//            //  Sign in with Email
//            NavigationLink {
//                SignInEmailView(showSignInView: $showSignInView)
//            } label: {
//                Text("Sign In with Email")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(height: 55)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
            
            //  Sign in with Google
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
            
//            //  Sign in with Apple
//            Button(action: {
//                Task {
//                    do {
//                        // try to sign in using Apple
//                        try await viewModel.signInApple()
//                        // turn off the SignInView
//                        showSignInView = false;
//                    } catch {
//                        print(error)
//                    }
//                }
//            }, label: {
//                SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
//                    .allowsHitTesting(false) // do not let user click it
//            })
//            .frame(height: 55)
            
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
