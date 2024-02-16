//
//  SignInAppleHelper.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/15/24.
//

import Foundation
import SwiftUI
import UIKit
import AuthenticationServices
import CryptoKit

// referenced https://github.com/SwiftfulThinking/SwiftfulFirebaseAuth/blob/main/Sources/SwiftfulFirebaseAuth/Helpers/SignInWithApple.swift

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

final class SignInAppleHelper: NSObject {
    
    // create a variable for the nonce string so it can be accessed later
    private var currentNonce: String?
    // create a variable for the completion block/closure so it can be accessed later
    private var completionHandler: ((Result<AppleSignInResultModel,Error>) -> Void)? = nil
    
    // Start Sign In With Apple and present OS modal.
    // Parameter viewController: ViewController to present OS modal on. If nil, function will attempt to find the top-most ViewController. Throws an error if no ViewController is found.
    @MainActor
    func startSignInWithAppleFlow(viewController: UIViewController? = nil) -> AsyncThrowingStream<AppleSignInResultModel, Error> {
        AsyncThrowingStream { continuation in
            startSignInWithAppleFlow { result in
                switch result {
                case .success(let appleSignInResult):
                    continuation.yield(appleSignInResult)
                    continuation.finish()
                    return
                case .failure(let error):
                    continuation.finish(throwing: error)
                    return
                }
            }
        }
    }
    
    @MainActor
    private func startSignInWithAppleFlow(viewController: UIViewController? = nil, completion: @escaping (Result<AppleSignInResultModel, Error>) -> Void) {
        // get the current top view controller
        guard let topVC = Utilities.shared.topViewController() else {
            // send back an error if we can't get the top view controller
            completion(.failure(SignInWithAppleError.noViewController))
            return
        }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        showOSPrompt(nonce: nonce, on: topVC)
    }
}

// MARK: PRIVATE
private extension SignInAppleHelper {
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
    
    private func showOSPrompt(nonce: String, on viewController: UIViewController) {
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
        authorizationController.presentationContextProvider = viewController
        
        // starts authorization flows (system displays Apple Sign-In prompts, interacts with the user, and communicates with Apple servers to verify credentials) and executes the delegate methods below (listeners who will execute certain functions based on what they 'hear')
        authorizationController.performRequests()
    }
    
    private enum SignInWithAppleError: LocalizedError {
        case noViewController
        case invalidCredential
        case badResponse
        case unableToFindNonce
        
        var errorDescription: String? {
            switch self {
            case .noViewController:
                return "Could not find top view controller."
            case .invalidCredential:
                return "Invalid sign in credential."
            case .badResponse:
                return "Apple Sign In had a bad response."
            case .unableToFindNonce:
                return "Apple Sign In token expired."
            }
        }
    }
}
    
extension SignInAppleHelper: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        do {
            guard let currentNonce else {
                throw SignInWithAppleError.unableToFindNonce
            }
            
            guard let result = AppleSignInResultModel(authorization: authorization, nonce: currentNonce) else {
                throw SignInWithAppleError.badResponse
            }
            
            completionHandler?(.success(result))
        } catch {
            completionHandler?(.failure(error))
            return
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completionHandler?(.failure(error))
        return
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
