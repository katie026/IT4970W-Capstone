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
    
    func addUserPosition(text: String) {
        guard let user else {return}
        
        Task {
            // add position to user in Firestore
            try await UserManager.shared.addUserPosition(userId: user.userId, position: text)
            // get updated user info from Firestore
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeUserPosition(text: String) {
        guard let user else {return}
        
        Task {
            // remove position to user in Firestore
            try await UserManager.shared.removeUserPosition(userId: user.userId, position: text)
            // get updated user info from Firestore
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addChairReport() {//chairType: String, chairCount: Int) {
        guard let user else {return}
        let chairReport = ChairReport(chairType: "001", chairCount: 20)
        
        Task {
            // add chair report to user in Firestore
            try await UserManager.shared.addChairReport(userId: user.userId, chairReport: chairReport)
            // get updated user info from Firestore
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeChairReport() {
        guard let user else {return}
        
        Task {
            // remove chair report to user in Firestore
            try await UserManager.shared.removeChairReport(userId: user.userId)
            // get updated user info from Firestore
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    let positionOptions: [String] = ["CO", "SS", "CS"]
    
    private func userHasPosition(text: String) -> Bool {
        viewModel.user?.positions?.contains(text) == true
    }
    
    var body: some View {
        List {
            // check if user is loaded
            if let user = viewModel.user {
                Text("UserId: \(user.userId)")
                
                // if user has email, display it
                if let email = user.email {
                    Text("Email: \(email)")
                }
                
                // toggle clock in status
                Button {
                    viewModel.toggleClockInStatus()
                } label: {
                    Text("User is clocked in: \((user.isClockedIn ?? false).description.capitalized)")
                }
                
                // add and remove positions from a user
                VStack {
                    HStack {
                        // make a button for each position option above
                        // positionOptions conforms to hashable (using id: \.self)
                        ForEach(positionOptions, id: \.self) { string in
                            Button(string) {
                                // if user has the position
                                if userHasPosition(text: string) {
                                    // delete the position
                                    viewModel.removeUserPosition(text: string)
                                } else {
                                    // otherwise add the position
                                    viewModel.addUserPosition(text: string)
                                }
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            // green if user already has position, red otherwise
                            .tint(userHasPosition(text: string) ? .green : .red)
                        }
                    }
                    
                    Text("User Positions: \((user.positions ?? []).joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // change map
                Button {
                    if user.chairReport == nil {
                        viewModel.addChairReport()
                    } else {
                        viewModel.removeChairReport()
                    }
                } label: {
                    Text("Chair Count: \(user.chairReport?.chairType ?? "N/A") - \(user.chairReport?.chairCount != nil ? String(user.chairReport!.chairCount) : "N/A")")
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
        RootView()
        //ProfileView(showSignInView: .constant(false))
    }
}
