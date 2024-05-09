//
//  AuthenticationView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/14/24.
//

import SwiftUI
import GoogleSignIn // can remove this if we use our own Google Button
import GoogleSignInSwift // can remove this if we use our own Google Button

struct AuthenticationView: View {
    // create a view model to hold functions
    @StateObject private var viewModel = AuthenticationViewModel()
    // recieve and link to the showSignInView variable that belongs to RootView
    @Binding var showSignInView: Bool
    // alerts
    @State private var showInvalidEmailAlert: Bool = false
    @State private var showNonAuthenticatedEmailAlert: Bool = false
    @State private var showInvalidLoginAlert: Bool = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(Color("MizzouGoldColor"))
                .rotationEffect(Angle(degrees: -20))
                .frame(width: UIScreen.main.bounds.width * 3,
                       height: 600)
                .offset(y: 250)
            
            Image("DoITBinaryLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .offset(y: -240)
                .offset(x: -30)
            
            VStack {
                Spacer()
                
                Text("SitesMobile")
                    .fontDesign(.monospaced)
                    .font(.system(size: 48))
                    .fontWeight(.heavy)
                Text("with the Univeristy of Misouri DoIT")
                    .padding(.bottom, 30)
                    .foregroundColor(.secondary)
                
                // Sign in with Google
                googleSignInButton
                    .padding(.horizontal)
                    .padding(.bottom, 180)
            }
        }
        .alert("Invalid Email", isPresented: $showInvalidEmailAlert) {
            Button("OK") { }
        } message: {
            Text("Email must end in umsystem.edu")
        }
        .alert("Email Not Authenticated", isPresented: $showNonAuthenticatedEmailAlert) {
            Button("OK") { }
        } message: {
            Text("Your email is valid but not yet authenticated. Please contact support.")
        }
        .alert("No Email", isPresented: $showInvalidLoginAlert) {
            Button("OK") { }
        } message: {
            Text("No Email Detected")
        }
    }
    
    private var anonymousSignInButton: some View {
        // Sign In Anonymously
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
    }
    
    private var emailSignInButton: some View {
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
    }
    
    private var googleSignInButton: some View {
        //  Sign in with Google
        Button {
            Task {
                do {
                    // try to sign in using Google
                    let signedIn = try await viewModel.signInGoogle()
                    if signedIn == true {
                        // turn off the SignInView
                        showSignInView = false
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                    if error.code == 401 {
                        showNonAuthenticatedEmailAlert = true
                    } else if error.code == 400 {
                        showInvalidEmailAlert = true
                    } else {
                        
                        //dont turn off signInView if user cant login(doesnt have authenticated email)
                        //show alert
                        showInvalidEmailAlert = true
                    }
                } catch {
                    print(error)
                }
            }
        } label: {
            HStack {
                Image("GoogleIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                Text("Sign in with Google")
                    .font(.headline)
                    .foregroundColor(Color.gray)
            }
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            
        }
        .background(Color.white)
        .cornerRadius(10)
        .frame(width: 340)
    }
    
    private var appleSignInButton: some View {
        //  Sign in with Apple
        Button(action: {
            Task {
                do {
                    // try to sign in using Apple
                    try await viewModel.signInApple()
                    // turn off the SignInView
                    showSignInView = false;
                } catch {
                    print(error)
                }
            }
        }, label: {
            SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                .allowsHitTesting(false) // do not let user click it
        })
        .frame(height: 55)
    }
}



#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
    }
}
