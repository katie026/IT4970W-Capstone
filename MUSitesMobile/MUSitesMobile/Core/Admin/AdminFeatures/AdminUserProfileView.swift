import SwiftUI
import Firebase

struct AdminUserProfileView: View {
    // Init
    @State var user: DBUser
    @State var isAuthorized: Bool
    @State var isAuthenticated: Bool
    // User Info
    @State var isAdmin: Bool = false
    @State var userPositions: [Position] = [] // initial values taken from given user
    @State private(set) var keySet: KeySet? = nil
    @State private(set) var keys: [Key]? = nil
    @State private(set) var keyTypeCodeMap: [String: String] = [:]
    // Current Selections
    @State private var selectedPosition: String?
    // View Control
    @State var currentUserId: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var showingConfirmation = false
    @State private var showingDeleteConfirmation = false
    @State private var keySetExpanded = false
    // References
    @State private var allPositions: [Position] = []
    // Alerts
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var activateAlert: AlertType = .none
    enum AlertType {
        case authentication, positionConfirmation, deleteConfirmation, none
    }
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let localTimezone =  TimeZone.current.abbreviation() ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy hh:mm a '\(localTimezone)'"
        return formatter
    }()

    var body: some View {
        VStack {
            profileTitleSection
            Form {
                basicInfoSection
                positionsSection(user: user)
                authorizationSection
                deleteSection
            }
        }
        .navigationTitle("User Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            getAllPositions()
            loadKeys() {}
            updateUserAdminStatus()
            currentUserId = Auth.auth().currentUser?.uid ?? "" // tell the view the current user's id
        }
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

    private var basicInfoSection: some View {
        Section(header: Text("Basic Information")) {
            Text("**Student ID:** \(user.studentId.map(String.init) ?? "N/A")")
            Text("**Email:** \(user.email ?? "N/A")")
            HStack {
                Text("**Status:**")
                Text("\(user.isClockedIn ?? false ? "Clocked In" : "Clocked Out")")
                    .foregroundStyle(user.isClockedIn ?? false ? .green : .red)
                Spacer()
            }
            keysGroup
            Text("Created: \(user.dateCreated != nil ? dateFormatter.string(from: user.dateCreated!) : "nil")")
            Text("Last Login: \(user.lastLogin != nil ? dateFormatter.string(from: user.lastLogin!) : "nil")")
        }
    }
    
    private var keysGroup: some View {
        DisclosureGroup(isExpanded: $keySetExpanded) {
            ForEach(keyTypeCodeMap.sorted(by: { $0.key < $1.key }), id: \.key) { keyValuePair in
                let (keyTypeId, keyCode) = keyValuePair
                Text("\(keyTypeId): \(keyCode)")
            }
        } label: {
            Text("**Key Set:** \(keySet?.name ?? "N/A")")
        }
    }
    
    private var authorizationSection: some View {
        Section(header: Text("Authorization")) {
            VStack(alignment: .leading) {
                if isAuthorized {
                    Text("User is authorized.").foregroundColor(.green)
                } else {
                    Text("User is not authorized.").foregroundColor(.red)
                }
                if isAuthorized {
                    Button("Remove User Authorization") {
                        AuthorizationManager.shared.removeUserToAuthorizedEmails(user: user) { error in
                            if let error = error {
                                alertMessage = "Failed to remove authorization: \(error.localizedDescription)"
                            } else {
                                alertMessage = "Removed user authorization successfully."
                                // update local view
                                isAuthorized = false
                            }
                            activateAlert = .authentication
                            showAlert = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                } else {
                    Button("Authorize User") {
                        AuthorizationManager.shared.addUserToAuthorizedEmails(user: user) { error in
                            if let error = error {
                                alertMessage = "Failed to authorize: \(error.localizedDescription)"
                            } else {
                                alertMessage = "User authorized successfully."
                                // update local view
                                isAuthorized = true
                            }
                            activateAlert = .authentication
                            showAlert = true
                        }
                        
//                        Firestore.firestore().collection("authenticated_emails").document(user.email ?? "").setData(["email": user.email ?? ""]) { error in
//                            if let error = error {
//                                alertMessage = "Failed to authorize: \(error.localizedDescription)"
//                            } else {
//                                alertMessage = "User authorized successfully."
//                                // update local view
//                                isAuthorized = true
//                            }
//                            activateAlert = .authentication
//                            showAlert = true
//                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
            VStack(alignment: .leading) {
                if isAdmin {
                    Text("User is an admin.").foregroundColor(.green)
                } else {
                    Text("User is not an admin.").foregroundColor(.red)
                }
                if isAdmin {
                    Button("Remove Admin Access") {
                        AdminManager.shared.removeUserFromAdminCollection(user: user) { error in
                            if let error = error {
                                alertMessage = "Failed to remove admin access: \(error.localizedDescription)"
                            } else {
                                alertMessage = "Access removed successfully."
                                // update local view
                                isAdmin = false
                                // if user just removed their own access, dismiss view
                                if currentUserId == user.id {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            activateAlert = .authentication
                            showAlert = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                } else {
                    Button("Grant Admin Access") {
                        AdminManager.shared.addUserToAdminCollection(user: user) { error in
                            if let error = error {
                                alertMessage = "Failed to grant admin access: \(error.localizedDescription)"
                            } else {
                                alertMessage = "Access granted successfully."
                                // update local view
                                isAdmin = true
                            }
                            activateAlert = .authentication
                            showAlert = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
            VStack(alignment: .leading) {
                if isAuthenticated {
                    Text("User has a linked authentication account.").foregroundColor(.green)
                } else {
                    Text("User does not have a linked authentication account.").foregroundColor(.red)
                }
            }
        }
    }

//    private var positionSection: some View {
//        Section(header: Text("Assign Position")) {
//            Button("CO") {
//                selectedPosition = "CO"
//                activateAlert = .positionConfirmation
//                showAlert = true
//            }.buttonStyle(PositionButtonStyle(isSelected: user.positionIds?.contains("CO") ?? false))
//
//            Button("SS") {
//                selectedPosition = "SS"
//                activateAlert = .positionConfirmation
//                showAlert = true
//            }.buttonStyle(PositionButtonStyle(isSelected: user.positionIds?.contains("SS") ?? false))
//
//            Button("CS") {
//                selectedPosition = "CS"
//                activateAlert = .positionConfirmation
//                showAlert = true
//            }.buttonStyle(PositionButtonStyle(isSelected: user.positionIds?.contains("CS") ?? false))
//        }
//    }
    
    private func userHasPosition(positionId: String) -> Bool {
        userPositions.contains(where: {$0.id == positionId}) == true
    }
    
    private func positionsSection(user: DBUser) -> some View {
        let view = Section ("Positions") {
            VStack {
                Text("**Positions**: \((userPositions.map{$0.nickname ?? ""}).joined(separator: ", "))")
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    // make a button for each position option above
                    // positionOptions conforms to hashable (using id: \.self)
                    ForEach(allPositions, id: \.self) { position in
                        Button(position.nickname ?? "N/A") {
                            // if user has the position
                            if userHasPosition(positionId: position.id) {
                                print("Button removing user position \(position.nickname ?? "?")")
                                // delete the position in Firestore and update userPositions
                                removeUserPosition(positionId: position.id)
                            } else {
                                print("Button adding user position \(position.nickname ?? "?")")
                                // otherwise add the position in Firestore and update userPositions
                                addUserPosition(positionId: position.id)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        // green if user already has position, red otherwise
                        .tint(userHasPosition(positionId: position.id) ? .green : .red)
                    }
                    
                    Spacer()
                }
            }
        }
        
        return AnyView(view)
    }
    
    private var deleteSection: some View {
        Section {
            Button("Delete User", role: .destructive) {
                activateAlert = .deleteConfirmation
                showAlert = true
            }
        }
    }
    
    private func addUserPosition(positionId: String) {
        Task {
            // add position to user in Firestore
            try await UserManager.shared.addUserPosition(userId: self.user.id, positionId: positionId)
            // update view locally
            if !userPositions.contains(where: { $0.id == positionId }) {
                if let newPosition = allPositions.first(where: { $0.id == positionId }) {
                    // add to userPosition list
                    userPositions.append(newPosition)
                    // sort userPosition list
                    userPositions.sort{ $0.positionLevel ?? 0 < $1.positionLevel ?? 0 }
                }
            }
        }
    }
    
    private func removeUserPosition(positionId: String) {
        Task {
            // remove position to user in Firestore
            try await UserManager.shared.removeUserPosition(userId: self.user.id, positionId: positionId)
            // update view locally
            if let posIndex = userPositions.firstIndex(where: { $0.id == positionId }) {
                userPositions.remove(at: posIndex)
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
                    self.user.positionIds = [position]
                }
            case .failure(let error):
                print("Failed to assign position: \(error.localizedDescription)")
            }
        }
    }

    private func deleteUser() {
        Task {
            do {
                try await UserManager.shared.deleteUser(userId: user.id)
            } catch {
                print("Error deleting user: \(error)")
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    private func getAllPositions() {
        Task {
            do {
                allPositions = try await PositionManager.shared.getAllPositions(descending: false)
            } catch {
                print("Error getting all positions: \(error)")
            }
            
            // load positions for the user
            // load the position names
            if let positionIds = self.user.positionIds {
                // for position in user's positionIds array
                for positionId in positionIds {
                    // find position using positionId
                    guard let position = allPositions.first(where: { $0.id == positionId }) else { continue }
                    // add to position list
                    userPositions.append(position)
                    print("adding \(position.nickname ?? "?") position to userPos list \(userPositions.count)")
                    // sort position list
                    userPositions.sort{ $0.positionLevel ?? 0 < $1.positionLevel ?? 0 }
                }
            }
        }
    }

    private var profileTitleSection: some View {
        HStack {
            if let photoURL = user.photoURL {
                AsyncImage(url: URL(string: photoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        // Loaded image
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .padding()
                    default:
                        // Placeholder content for loading state
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .padding()
                    }
                }
            }
            Text(user.fullName ?? "Unknown")
                .font(.title)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private func loadKeys(completion: @escaping () -> Void) {
        Task {
            do {
                // get optional key set
                self.keySet = try await KeySetManager.shared.getKeySetForUser(userId: user.id)
                // get optional keys for set
                self.keys = try await KeyManager.shared.getKeysForKeySet(keySetId: keySet?.id ?? "")
                
                // fetch key type for each key and add to dictionary
                for key in keys ?? [] {
                    do {
                        let keyType = try await KeyTypeManager.shared.getKeyType(keyTypeId: key.keyType ?? "")
                        keyTypeCodeMap[keyType.name] = key.keyCode
                    } catch {
                        print("Error fetching key types: \(error)")
                    }
                }
            } catch {
                print("Error loading keys: \(error)")
            }
            completion()
        }
    }
    
    private func updateUserAdminStatus() {
        AdminManager.shared.checkIfUserIsAdmin(userId: user.id) { isAdminResult in
            self.isAdmin = isAdminResult
        }
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
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

#Preview {
    AdminUserProfileView(
        user: DBUser(
            userId: "UP4qMGuLhCP3qHvT5tfNnZlzH4h1",
            studentId: 12572353,
            isAnonymous: false,
            hasAuthentication: true,
            email: "tmwny4@umsystem.edu",
            fullName: "Tristan Winship",
            photoURL: "https://lh3.googleusercontent.com/a/ACg8ocJxVcI6q24DRgPDw3dz1lVJLowgsgaXiARzj9lMBGxS=s96-c",
            dateCreated: Date(),
            lastLogin: Date(),
            isClockedIn: true,
            positionIds: ["1HujvaLNHtUEs59nTdci", "FYK5L6XdE4YE5kMpDOyr", "xArozhlNGujNsgczkKsr"],
//            positionIds: [],
            chairReport: nil
        ),
        isAuthorized: false,
        isAuthenticated: true
    )
}
