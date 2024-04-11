import Foundation
import SwiftUI
import Firebase

struct AdminUserProfileView: View {
    var user: DBUser
    @State private var showingConfirmation = false
    @State private var selectedPosition: String?
    @State private var showingDeleteConfirmation = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Basic Information")) {
                    Text("**ID:** \(user.studentId.map(String.init) ?? "N/A")")
                    Text("**Email:** \(user.email ?? "N/A")")
                }
                Section(header: Text("Assign Position")) {
                    HStack {
                        ForEach(["CO", "SS", "CS"], id: \.self) { position in
                            Button(position) {
                                selectedPosition = position
                                showingConfirmation = true
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        }
                    }
                }
                Section {
                    Button("Delete User", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }
            }
        }
        .navigationTitle("User Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Confirm Position", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Assign") {
                assignPosition()
            }
        } message: {
            Text("Are you sure you want to assign the position \(selectedPosition ?? "N/A") to \(user.fullName ?? "this user")?")
        }
        .alert("Confirm Delete", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteUser()
            }
        } message: {
            Text("Are you sure you want to delete \(user.fullName ?? "this user")? This action cannot be undone.")
        }
    }

    private func assignPosition() {
        guard let position = selectedPosition else { return }
        
        UserManager.shared.updateUserPositions(userId: user.id, positions: [position]) { result in
            switch result {
            case .success(_):
                print("Position \(position) assigned to user \(user.fullName ?? "Unkown") successfuly")
            case .failure(let error):
                print("Failed to assign position: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    private func deleteUser() {
        let userId = user.id

        let db = Firestore.firestore()
        db.collection("users").document(userId).delete { error in
            if let error = error {
                // Handle the error, e.g., show an alert to the admin
                print("Error deleting user: \(error.localizedDescription)")
            } else {
                // Successfully deleted the user
                print("User successfully deleted")
                // Dismiss the view after deleting the user
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}


