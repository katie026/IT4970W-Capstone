// NonAuthUsersViewModel.swift
import SwiftUI
import Firebase

@MainActor
final class NonAuthUsersViewModel: ObservableObject {
    @Published private(set) var users: [DBUser] = []
    
    func getNonAuthUsers() {
        let db = Firestore.firestore()
        // Fetch the list of all users
        db.collection("users").getDocuments { [weak self] (usersSnapshot, error) in
            if let error = error {
                print("Error getting users: \(error.localizedDescription)")
                return
            }

            guard let documents = usersSnapshot?.documents else {
                print("Error: usersSnapshot is nil")
                return
            }

            let allUsers = documents.compactMap { document -> DBUser? in
                // Create a DBUser instance from the document
                return DBUser(
                    userId: document.documentID,
                    studentId: document.get("studentId") as? Int,
                    isAnonymous: document.get("isAnonymous") as? Bool,
                    hasAuthentication: document.get("hasAuthentication") as? Bool,
                    email: document.get("email") as? String,
                    fullName: document.get("full_name") as? String,
                    photoURL: document.get("photo_url") as? String,
                    dateCreated: (document.get("dateCreated") as? Timestamp)?.dateValue(),
                    isClockedIn: document.get("isClockedIn") as? Bool,
                    positions: document.get("positions") as? [String],
                    chairReport: nil // Handle ChairReport creation based on your data structure
                )
            }

            // Fetch the list of authenticated emails
            db.collection("authenticated_emails").getDocuments { (authEmailsSnapshot, error) in
                if let error = error {
                    print("Error getting authenticated emails: \(error.localizedDescription)")
                    return
                }

                let authEmails = Set(authEmailsSnapshot?.documents.map { $0.documentID } ?? [])
                
                // Filter out the authenticated users
                DispatchQueue.main.async {
                    self?.users = allUsers.filter { !authEmails.contains($0.email ?? "") }
                }
            }
        }
    }
    public func deleteUserDoc(userId: String) {
        Task {
            // Assuming UserManager.shared.deleteUser is implemented
            // and deletes the user from Firestore
            try await UserManager.shared.deleteUser(userId: userId)
            DispatchQueue.main.async {
                print("user deleted")
            }
            // After deletion, refresh the list of non-authenticated users
            await getNonAuthUsers()
        }
    }
}

//DetailedUserView.swift
//struct DetailedUserView: View {
//    let user: DBUser
//    
//    var body: some View {
//        ZStack {
//            // Background
//            LinearGradient(
//                gradient: Gradient(colors: [.green, .white]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .edgesIgnoringSafeArea(.top)
//            
//            VStack(spacing: 16) {
//                // Header
//                Text(user.fullName ?? "N/A")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                
//                Text(user.email ?? "N/A")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                
//                // if user has name, display it
//                if let name = user.fullName {
//                    Text("Name: \(name)")
//                }
//                
//                // photo url
//                if let photoURL = user.photoURL {
//                    AsyncImage(url: URL(string: photoURL))
//                }
//                
//                Spacer()
//            }
//            .padding()
//        }
//        .navigationTitle("User Info")
//    }
//}

// NonAuthUsersView.swift
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
            viewModel.getNonAuthUsers()
        }
    }
}

// NonAuthUserCellView.swift
struct NonAuthUserCellView: View {
    let user: DBUser
    
    var body: some View {
        NavigationLink(destination: DetailedUserView(user: user)) {
            HStack(alignment: .top) {
                AsyncImage(url: URL(string: user.photoURL ?? "https://wvnpa.org/content/uploads/blank-profile-picture-973460_1280.png")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading) {
                    Text(user.email ?? "N/A")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("ID: \(user.userId)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
            }
        }
    }
}


