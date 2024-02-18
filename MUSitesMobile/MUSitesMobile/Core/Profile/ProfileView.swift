//
//  ProfileView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/16/24.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    // ObservableObject means any changes to ProfileViewModel will trigger re-rendering of associated views
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        // get authData for current user
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        // use authData to get user data from Firestore as DBUser struct
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func toggleClockInStatus() {
        // check if current user exists
        guard let user else { return }
        // get currentValue of isClockedIn, if nil return currentValue as false
        let currentValue = user.isClockedIn ?? false
        Task {
            // swap currentValue and send updated user info to Firestore
            try await UserManager.shared.updateUserClockInStatus(userId: user.userId, isClockedIn: !currentValue)
            // get updated user info from Firestore
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            // check if user is loaded
            if let user = viewModel.user {
                Text("UserId: \(user.userId)")
                
                // if user has email, display it
                if let email = user.email {
                    Text("Email: \(email)")
                }
                
                Button {
                    viewModel.toggleClockInStatus()
                } label: {
                    Text("User is clocked in: \((user.isClockedIn ?? false).description.capitalized)")
                }
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink{
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                    .font(.headline)}
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
