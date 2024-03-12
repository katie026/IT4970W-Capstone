//
//  NonAuthUsersView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/12/24.
//

import SwiftUI

@MainActor
final class NonAuthUsersViewModel: ObservableObject {
    @Published private(set) var users: [DBUser] = []
    
    func getNonAuthUsers() {
        Task {
            self.users = try await UserManager.shared.getNonAuthenticatedUsers()
        }
    }
    
    func deleteUserDoc(userId: String) {
        Task {
            try await UserManager.shared.deleteUser(userId: userId)
        }
    }
}

struct NonAuthUsersView: View {
    @StateObject private var viewModel = NonAuthUsersViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.users) { user in
                NonAuthUserCellView(user: user)
                    .contextMenu {
                        Button("Delete user profile.") {
                            viewModel.deleteUserDoc(userId: user.userId)
                        }
                    }
            }
        }
        .navigationTitle("Non-Auth Users")
        .onAppear {
            Task {
                viewModel.getNonAuthUsers()
            }
        }
    }
}

#Preview {
    NavigationView {
        NonAuthUsersView()
    }
}
