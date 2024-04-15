import SwiftUI
import Firebase

struct AdminUserProfileView: View {
    @State var user: DBUser
    @State private var showingConfirmation = false
    @State private var selectedPosition: String?
    @State private var showingDeleteConfirmation = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            profileTitleSection
            Form {
                Section(header: Text("Basic Information")) {
                    Text("**ID:** \(user.studentId.map(String.init) ?? "N/A")")
                    Text("**Email:** \(user.email ?? "N/A")")
                }
                Section(header: Text("Assign Position")) {
                    Button("CO") {
                        selectedPosition = "CO"
                        showingConfirmation = true
                    }.buttonStyle(PositionButtonStyle(isSelected: user.positions?.contains("CO") ?? false))
                    
                    Button("SS") {
                        selectedPosition = "SS"
                        showingConfirmation = true
                    }.buttonStyle(PositionButtonStyle(isSelected: user.positions?.contains("SS") ?? false))

                    Button("CS") {
                        selectedPosition = "CS"
                        showingConfirmation = true
                    }.buttonStyle(PositionButtonStyle(isSelected: user.positions?.contains("CS") ?? false))
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
                assignPosition(selectedPosition ?? "")
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

    private func assignPosition(_ position: String) {
        print("Assigning position: \(position)")
        UserManager.shared.updateUserPosition(userId: user.id, newPosition: position) { result in
            switch result {
            case .success(_):
                print("Position \(position) assigned to user \(user.fullName ?? "Unknown") successfully.")
                DispatchQueue.main.async {
                    self.user.positions = [position]
                }
            case .failure(let error):
                print("Failed to assign position: \(error.localizedDescription)")
            }
        }
    }

    private func deleteUser() {
        let userId = user.id
        let db = Firestore.firestore()
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
            } else {
                print("User successfully deleted")
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    private var profileTitleSection: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding()
            Text(user.fullName ?? "Unknown")
                .font(.title)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct PositionButtonStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.red : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(5)
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
    }
}

