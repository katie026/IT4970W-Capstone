//
//  RootView.swift
//  MUSitesMobile
//
//  Created by J Kim on 2/14/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                SettingsView(showSignInView: $showSignInView)
                // pass and bind showSignInView variable to the SettingsView, so that it can change this value
            }
        }
        // first check if the user is authenticated
        .onAppear() {
            // check user auth status
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            // if authUser is nil, return true, otherwise false
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView()
            }
        }
    }
}

#Preview {
    RootView()
}
