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
    // ObservableObject protocol allows models to publish changes to their properties using the @Published and trigger reactive UI updates
    @Published var didSignInWithApple: Bool = false
    
    // Sign in with Google
    func signInGoogle() async throws {
        // create a SignInGoogleHelper
        let helper = SignInGoogleHelper()
        // get Google Sign In result model from Google using SignInGoogleHelper
        let googleSignInResult = try await helper.signIn()
        // now try to log into Firebase using Google result (holds the tokens)
        try await AuthenticationManager.shared.signInWithGoogle(googleSignInResult: googleSignInResult)
    }
    
    // Sign in with Apple
    func signInApple() async throws {
        // create a SignInAppleHelper
        let signInAppleHelper = SignInAppleHelper()
        
        // start the SignInWithAppleFlow
        signInAppleHelper.startSignInWithAppleFlow { result in
            // function uses completion handler to make sure helper stays alive and doesn't get deallocated when running this async method
            // call startSignInWithAppleFlow and pass it this code block as the completion handler
                // result is a placeholder for the value that will be received later
            // code can continue while waiting for the results of startSignInWithAppleFlow (as the user interacts with Sign-In prompts)
            // once Sign-In finishes, the system calls this completion handler block and replaces the result placeholder with the Result(.success/.error)
            
            // this switch statement within the block examines the result and handles it
            switch result {
            // if result is a success
            case .success(let appleSignInResult):
                Task {
                    do {
                        // try to sign in to Firebase using Apple credentials
                        try await AuthenticationManager.shared.signInWithApple(appleSignInResult: appleSignInResult)
                        // tell the view the user signed in with Apple
                        self.didSignInWithApple = true
                    } catch {
                        
                    }
                }
            // if result is a failure
            case .failure(let error):
                print(error)
            }
        }
    }
    
}



struct AuthenticationView: View {
    // create a view model to hold functions
    @StateObject private var viewModel = AuthenticationViewModel()
    // recieve and link to the showSignInView variable that belongs to RootView
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            //  Sign in with Email
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
            
            //  Sign in with Apple
            Button(action: {
                Task {
                    do {
                        // try to sign in using Apple
                        try await viewModel.signInApple()
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                    .allowsHitTesting(false) // do not let user click it
            })
            .frame(height: 55)
            // if Apple sign in is successful, turn off the SignInView
            .onChange(of: viewModel.didSignInWithApple) { oldValue, newValue in
                if newValue == true {
                    showSignInView = false
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
