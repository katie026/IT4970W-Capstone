//
//  ProfileView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/16/24.
//

import SwiftUI

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