//
//  SignInGoogleHelper.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/15/24.
//

import Foundation
import SwiftUI
import UIKit
import GoogleSignIn
import GoogleSignInSwift

// using SwiftfulThinking SignInWithGoogle.swift from GitHub

// creating our own GIDSignInResult model from Google's
struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let fullName: String?
    let profileImageUrl: URL?
    
    var displayName: String? {
        // use the full name, otherwise use first name, otherwise use last name
        fullName ?? firstName ?? lastName
    }
    
    init?(result: GIDSignInResult) { // will return nil if init fails
        // try to get an id token, if failed, return nil
        guard let idToken = result.user.idToken?.tokenString else {
            return nil
        }
        
        // if there is an id token, initialize these fields
        self.idToken = idToken
        self.accessToken = result.user.accessToken.tokenString
        self.email = result.user.profile?.email
        self.firstName = result.user.profile?.givenName
        self.lastName = result.user.profile?.familyName
        self.fullName = result.user.profile?.name
        
        // if there is a profile picture, initialize the image url
        let dimension = round(400 * UIScreen.main.scale)
        if result.user.profile?.hasImage == true {
            self.profileImageUrl = result.user.profile?.imageURL(withDimension: UInt(dimension))
        } else {
            self.profileImageUrl = nil
        }
    }
}

final class SignInGoogleHelper {
    
    @MainActor // must be on main thread since its accessing the view controller
    func signIn() async throws -> GoogleSignInResultModel{
        // get the current top view controller
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost) // cusotmize error here
        }
        
        // get Google credentials using GoogleSignIn SDK
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        // create a Google Sign In Result model using Google credentials
        guard let result = GoogleSignInResultModel(result: gidSignInResult) else {
            throw GoogleSignInError.badResponse
        }
        
        return result
    }
    
    // custom error
    private enum GoogleSignInError: LocalizedError {
        case noViewController
        case badResponse
        
        var errorDescription: String? {
            switch self {
            case .noViewController:
                return "Could not find top view controller."
            case .badResponse:
                return "Google Sign In had a bad response."
            }
        }
    }
}
