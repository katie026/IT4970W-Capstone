//
//  ViewUsersView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 3/26/24.
//
import SwiftUI
import Firebase

@MainActor
final class ViewUsersViewModel: ObservableObject {
    @Published var users: [DBUser] = []
    @Published var isAuthenticated: [String: Bool] = [:]
    @Published var unLinked: [String: Bool] = [:]

    
    func loadUsers(completion: @escaping () -> Void) {
        Task {
            UserManager.shared.getAllUsers { result in
                switch result {
                case .success(let fetchedUsers):
                    self.users = fetchedUsers
                    self.checkAuthentication(for: fetchedUsers)
                case .failure(let error):
                    print(error.localizedDescription)
                }
                completion()
            }
        }
    }
    
    private func checkAuthentication(for users: [DBUser]) {
        for user in users {
            guard let email = user.email else { continue }
            let docRef = Firestore.firestore().collection("authenticated_emails").document(email)
            docRef.getDocument { document, error in
                if let document = document, document.exists {
                    self.isAuthenticated[email] = true
                } else {
                    self.isAuthenticated[email] = false
                }
            }
        }
    }
    
    func loadNonAuthenticatedUsers(completion: @escaping () -> Void) {
        Task {
            do {
                let nonAuthenticatedUsers = try await UserManager.shared.getNonAuthenticatedUsers()
                for user in nonAuthenticatedUsers {
                    guard let email = user.email else { continue }
                    self.unLinked[email] = true // Assume true for simplicity, adjust logic as needed
                }
                completion()
            } catch {
                print(error.localizedDescription)
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
    @State private var filterMode: FilterMode = .all
    
    enum FilterMode: String, CaseIterable {
        case all = "All"
        case authenticated = "Authenticated"
        case nonAuthenticated = "Non-Authenticated"
        case unLinked = "unLinked"
    }

    var body: some View {
        VStack {
            Picker("Filter", selection: $filterMode) {
                ForEach(FilterMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            TextField("Search", text: $searchText)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            
//            List(sortedUsers) { user in
//                NavigationLink(destination: AdminUserProfileView(user: user)) {
//                    VStack(alignment: .leading) {
//                        Text(user.fullName ?? "No Name").font(.headline)
//                        Text(user.email ?? "No Email").font(.subheadline)
//                    }
//                }
//            }
            List(filteredUsers) { user in
                NavigationLink(destination: AdminUserProfileView(user: user, isAuthenticated: viewModel.isAuthenticated[user.email ?? ""] ?? false)) {
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
            viewModel.loadNonAuthenticatedUsers {
                isLoading = false
            }
        }

        .overlay {
            if isLoading {
                ProgressView("Loading users...")
            }
        }
    }
    
//    private var filteredUsers: [DBUser] {
//        var result = viewModel.users
//        
//        if filterMode != .all {
//            result = result.filter {
//                ($0.email != nil) && (viewModel.isAuthenticated[$0.email!] == (filterMode == .authenticated))
//            }
//        }
//        
//        if !searchText.isEmpty {
//            result = result.filter {
//                $0.fullName?.localizedCaseInsensitiveContains(searchText) ?? false
//            }
//        }
//        
//        return result.sorted { $0.fullName?.localizedCaseInsensitiveCompare($1.fullName ?? "") == .orderedAscending }
//    }
    
    private var filteredUsers: [DBUser] {
        var result = viewModel.users
        
        switch filterMode {
        case .all:
            break
        case .authenticated:
            result = result.filter { user in
                (user.email != nil) && (viewModel.isAuthenticated[user.email!] == true)
            }
        case .nonAuthenticated:
            result = result.filter { user in
                (user.email != nil) && (viewModel.isAuthenticated[user.email!] == false)
            }
        case .unLinked:
            result = result.filter { user in
                guard let email = user.email else { return false }
                return self.viewModel.unLinked[email, default: false] // Default to false if not set
            }

        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.fullName?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        return result.sorted { $0.fullName?.localizedCaseInsensitiveCompare($1.fullName ?? "") == .orderedAscending }
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
