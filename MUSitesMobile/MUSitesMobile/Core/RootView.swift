//
//  RootView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/14/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    // @State will allow the view to update based on the value of this bool whenever it changes
    
    var body: some View {
        ZStack {
            // if user is logged in, show the Settings View
            if !showSignInView {
                TabBarView(showSignInView: $showSignInView)
            }
        }
        // FIRST check if the user is authenticated
        .onAppear() {
            // check the user auth status
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            // show the SignInView if user is not logged in
            self.showSignInView = authUser == nil // authUser will return true if user is authenticated, nil if not
        }
        // show sign in view if showSignInView is true
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
                // pass and bind showSignInView variable to the AuthView, so that it can change this value
            }
        }
    }
}

#Preview {
    RootView()
}
