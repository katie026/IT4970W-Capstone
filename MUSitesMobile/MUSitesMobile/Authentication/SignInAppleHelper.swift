//
//  SignInAppleHelper.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/15/24.
//

import Foundation
import SwiftUI // may need to be UIKit
import AuthenticationServices
import CryptoKit

// this method may be deprecated now, we may need to reference https://github.com/SwiftfulThinking/SwiftfulFirebaseAuth/blob/main/Sources/SwiftfulFirebaseAuth/Helpers/SignInWithApple.swift to update it

// creating our own AppleSignInResultModel to send to Firebase
struct AppleSignInResultModel {
    // required for Firebase login request
    let idToken: String
    let nonce: String
    let fullNameComponents: PersonNameComponents
    
    // optional
    let email: String?
    let firstName: String?
    let lastName: String?
    let nickName: String?
    var fullName: String? {
        if let firstName, let lastName {
            return firstName + " " + lastName
        } else if let firstName {
            return firstName
        } else if let lastName {
            return lastName
        }
        return nil
    }
    var displayName: String? {
        // use the full name, otherwise use nickname
        fullName ?? nickName
    }
    
    init?(authorization: ASAuthorization, nonce: String) { // will return nil if init fails
        // use the ASAuthorization to try and create an ASAuthorizationAppleIDCredential and extract the credential values
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let fullName = appleIDCredential.fullName,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else {
            // if failed, return nil
            return nil
        }
        
        // if we got an ASAuthorizationAppleIDCredential
        self.idToken = idTokenString
        self.nonce = nonce
        self.email = appleIDCredential.email
        self.fullNameComponents = fullName
        self.firstName = appleIDCredential.fullName?.givenName
        self.lastName = appleIDCredential.fullName?.familyName
        self.nickName = appleIDCredential.fullName?.nickname
    }
}

struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    // UIViewRepresentable converts a UIKit view into a representable version of it in SwiftUI
    // we can use the UIKit view like any other SwiftUI view
    
    // define type and style of AppleID button
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    // create the UI Control button/SwiftUI view using specifications
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        
        return ASAuthorizationAppleIDButton(type: type, style: style)
    }
    
    // update the UIKit view if any properties change
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}

@MainActor
final class SignInAppleHelper: NSObject {
    
    // create a variable for the nonce string so it can be accessed later
    private var currentNonce: String?
    // create a variable for the completion block/closure so it can be accessed later
    private var completionHandler: ((Result<AppleSignInResultModel,Error>) -> Void)? = nil
    
    // using continuation to bridge gap between older completion handlers and new Concurrency
    func signInWithAppleFlow() async throws -> AppleSignInResultModel {
        // withCheckedThrowingContinuation takes a closure and suspends startSignInWithAppleFlow's execution while the sign-in process happens in the background
        try await withCheckedThrowingContinuation { continuation in
            // begin asynchronous sign-in process and pass control to the continuation (instead of waiting for it to finish and returning a Result)
            // once startSignInWithAppleFlow finishes, it calls the completion handler to be evaluated
            self.signInWithAppleFlow { result in
                switch result {
                // if result is a success, receive appleSignInResult
                case .success(let appleSignInResult):
                    continuation.resume(returning: appleSignInResult) // trigger the continuation to resume its execution and provides the appleSignInResult
                    return
                // if result is a failure, receive an error
                case .failure(let error):
                    continuation.resume(throwing: error) // trigger the continuation to resume its execution and throws the error
                    return
                }
            }
        }
    }
    
    // start the flow for SignInWithApple
    // Adopted from https://firebase.google.com/docs/auth/ios/apple?hl=en&authuser=0
    func signInWithAppleFlow(completion: @escaping (Result<AppleSignInResultModel,Error>) -> Void) {
        // we need a completion handler so we can send the result back to where we called this function (our app)
        // function accepts a closure (called completion) as a parameter; using a closure creates an asynchronous operation without directly waiting for the sign-in flow to finish
        // @escaping means closure can be stored/executed after the function finishes aka it allows asynchronous operations
        // we'll return a Result (generic type) which includes a success value (the appleSignInResult) or an error
        
        // get the current top view controller
        guard let topVC = Utilities.shared.topViewController() else {
            // send back an error if we can't get the top view controller
            completion(.failure(URLError(.badURL))) // customize this error!
            return
        }
        
        // create a nonce
        let nonce = randomNonceString()
        currentNonce = nonce
        
        // create the completion handler
        completionHandler = completion
        
        // get provider to create Apple ID auth request
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        // create Apple ID authorization request
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        // create an authorization controller from collection of authorization requests
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        // provide display context where system can present the auth interface to user
        authorizationController.presentationContextProvider = topVC
        // starts authorization flows (system displays Apple Sign-In prompts, interacts with the user, and communicates with Apple servers to verify credentials) and executes the delegate methods below (listeners who will execute certain functions based on what they 'hear')
        authorizationController.performRequests()
    }
    
    // function to generate a nonce
    // Adopted from https://firebase.google.com/docs/auth/ios/apple?hl=en&authuser=0
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    // function to hash a string
    // Adopted from https://firebase.google.com/docs/auth/ios/apple?hl=en&authuser=0
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

// extend helper so this code can conform to the protocol
extension SignInAppleHelper: ASAuthorizationControllerDelegate {
    // ASAuthorizationControllerDelegate protocol means it acts as a "delegate" or a listener for events related to Apple Sign-In, it can receive updates about the Sign-In process
    // when events happen (ex. sign-in/error), the ASAuthorizationController from above calls these specific functions
    
    // called when Apple Sign-In is successful
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // pass the ASAuthorization that was passed to this function when sign-in was successful and try to create an AppleSignInResultModel object
        guard
            let nonce = currentNonce,
            let appleSignInResult = AppleSignInResultModel(authorization: authorization, nonce: nonce) else {
            // send the completionHandler the error
            completionHandler?(.failure(URLError(.badServerResponse))) // customize the error here
            return
        }

        // send the completionHandler the success
        completionHandler?(.success(appleSignInResult))
    }
    
    // called if Apple Sign-In encounters an error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
        // send the completionHandler the error
        completionHandler?(.failure(URLError(.cannotFindHost))) // customize the error here
    }
    
}

// extend the UIViewController so this code can conform to the protocol
extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // we need to return an anchor for the Apple sign in flow to present on
        return self.view.window! // window is a container for the controller
        // any view controller has a view, which will have a window, so it is sfaer to force unwrap this
    }

}
