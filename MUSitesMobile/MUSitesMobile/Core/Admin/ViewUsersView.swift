//
//  ViewUsersView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 3/26/24.
//
import SwiftUI

@MainActor
final class ViewUsersViewModel: ObservableObject {
    @Published var users: [DBUser] = []
    
    func loadUsers(completion: @escaping () -> Void) {
        Task {
            UserManager.shared.getAllUsers { result in
                switch result {
                case .success(let fetchedUsers):
                    self.users = fetchedUsers
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
                completion()
            }
        }
    }
}

struct ViewUsersView: View {
    // View Model
    @StateObject private var viewModel = ViewUsersViewModel()
    // Search Bar
    @State private var searchText = ""
    // View Control
    @State private var isLoading = true

    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            
//            List(sortedUsers) { user in
//                VStack(alignment: .leading) {
//                    Text(user.fullName ?? "No Name")
//                        .font(.headline)
//                    Text(user.email ?? "No Email")
//                        .font(.subheadline)
//                }
//            }
            List(sortedUsers) { user in
                NavigationLink(destination: AdminUserProfileView(user: user)) {
                    VStack(alignment: .leading) {
                        Text(user.fullName ?? "No Name").font(.headline)
                        Text(user.email ?? "No Email").font(.subheadline)
                    }
                }
            }

        }
        .navigationTitle("User Accounts")
        .onAppear {
            isLoading = true
            viewModel.loadUsers {
                isLoading = false
            }
        }
        .overlay {
            if isLoading {
                ProgressView("Loading users...")
            }
        }
    }
    
    //TODO: create option to sort by other properties
    private var sortedUsers: [DBUser] {
        if searchText.isEmpty {
            return viewModel.users.sorted { $0.fullName?.localizedCaseInsensitiveCompare($1.fullName ?? "") == .orderedAscending }
        } else {
            return viewModel.users.filter {
                $0.fullName?.localizedCaseInsensitiveContains(searchText) ?? false
            }
            .sorted { $0.fullName?.localizedCaseInsensitiveCompare($1.fullName ?? "") == .orderedAscending }
        }
    }
}

#Preview {
    NavigationStack {
        ViewUsersView()
    }
}
