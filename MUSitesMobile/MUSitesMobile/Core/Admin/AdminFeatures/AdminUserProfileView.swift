import SwiftUI
import Firebase

struct AdminUserProfileView: View {
    @State var user: DBUser
    var isAuthenticated: Bool
    @State private var showingConfirmation = false
    @State private var selectedPosition: String?
    @State private var showingDeleteConfirmation = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var activateAlert: AlertType = .none
    enum AlertType {
        case authentication, positionConfirmation, deleteConfirmation, none
    }

    var body: some View {
        VStack {
            profileTitleSection
            Form {
                Section(header: Text("Basic Information")) {
                    Text("**ID:** \(user.studentId.map(String.init) ?? "N/A")")
                    Text("**Email:** \(user.email ?? "N/A")")
                    if isAuthenticated {
                        Text("User is authenticated.").foregroundColor(.green)
                    } else {
                        Text("User is Not authenticated.").foregroundColor(.red)
                    }
                    Button("Authenticate User") {
                        Firestore.firestore().collection("authenticated_emails").document(user.email ?? "").setData(["email": user.email ?? ""]) { error in
                            if let error = error {
                                alertMessage = "Failed to authenticate: \(error.localizedDescription)"
                            } else {
                                alertMessage = "User authenticated successfully."
                            }
                            activateAlert = .authentication
                            showAlert = true
                        }
                    }
                }
                Section(header: Text("Assign Position")) {
                    Button("CO") {
                        selectedPosition = "CO"
                        activateAlert = .positionConfirmation
                        showAlert = true
                    }.buttonStyle(PositionButtonStyle(isSelected: user.positions?.contains("CO") ?? false))
                    
                    Button("SS") {
                        selectedPosition = "SS"
                        activateAlert = .positionConfirmation
                        showAlert = true
                    }.buttonStyle(PositionButtonStyle(isSelected: user.positions?.contains("SS") ?? false))

                    Button("CS") {
                        selectedPosition = "CS"
                        activateAlert = .positionConfirmation
                        showAlert = true
                    }.buttonStyle(PositionButtonStyle(isSelected: user.positions?.contains("CS") ?? false))
                }
                Section {
                    Button("Delete User", role: .destructive) {
                        activateAlert = .deleteConfirmation
                        showAlert = true
                    }
                }
            }
        }
        .navigationTitle("User Details")
        .navigationBarTitleDisplayMode(.inline)
//        .alert("Confirm Position", isPresented: $showingConfirmation) {
//            Button("Cancel", role: .cancel) {}
//            Button("Assign") {
//                assignPosition(selectedPosition ?? "")
//            }
//        } message: {
//            Text("Are you sure you want to assign the position \(selectedPosition ?? "N/A") to \(user.fullName ?? "this user")?")
//        }
//        .alert("Confirm Delete", isPresented: $showingDeleteConfirmation) {
//            Button("Cancel", role: .cancel) {}
//            Button("Delete", role: .destructive) {
//                deleteUser()
//            }
//        } message: {
//            Text("Are you sure you want to delete \(user.fullName ?? "this user")? This action cannot be undone.")
//        }
        .alert(isPresented: $showAlert) {
            switch activateAlert {
            case .authentication:
                return Alert(title: Text("Authentication Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            case .positionConfirmation:
                return Alert(title: Text("Confirm Position"), message: Text("Are you sure you want to assign the position \(selectedPosition ?? "N/A") to \(user.fullName ?? "this user")?"), primaryButton: .cancel(), secondaryButton: .default(Text("Assign"), action: {
                    assignPosition(selectedPosition ?? "")
                }))
            case .deleteConfirmation:
                return Alert(title: Text("Confirm Delete"), message: Text("Are you sure you want to delete \(user.fullName ?? "this user")? This action cannot be undone."), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete"), action: {
                    deleteUser()
                }))
            case .none:
                return Alert(title: Text("Error"), message: Text("Unexpected alert type"))
            }
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

