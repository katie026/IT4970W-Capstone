//
//  ViewUsersView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 3/26/24.
//
import SwiftUI

struct ViewUsersView: View {
    @State private var users = [DBUser]()
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        List(users) { user in
            VStack(alignment: .leading) {
                Text(user.fullName ?? "No Name")
                    .font(.headline)
                Text(user.email ?? "No Email")
                    .font(.subheadline)
            }
        }
        .navigationTitle("View Users")
        .onAppear {
            isLoading = true
            UserManager.shared.getAllUsers { result in
                switch result {
                case .success(let fetchedUsers):
                    self.users = fetchedUsers
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
                self.isLoading = false
            }
        }
        .overlay {
            if isLoading {
                ProgressView("Loading users...")
            }
        }
    }
}

