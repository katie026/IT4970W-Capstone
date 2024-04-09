//
//  ProfileView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/16/24.
//

import SwiftUI

struct ProfileView: View {
    // View Model
    @StateObject private var viewModel = ProfileViewModel()
    
    @Binding var showSignInView: Bool
    @State private var isAdmin: Bool = false
    
    // Disclosure Groups
    @State private var keySetExpanded = false
    
    let positionOptions: [String] = ["CO", "SS", "CS"]
    
    private func userHasPosition(text: String) -> Bool {
        viewModel.user?.positions?.contains(text) == true
    }
    
    var body: some View {
        VStack {
            // check if user is loaded
            if let user = viewModel.user {
                List {
                    // Profile title
                    profileTitleSection(user: user)
                    
                    // Info Section
                    Section("Basic Information") {
                        // STUDENT ID
                        Text("**ID:** \(user.studentId.map(String.init) ?? "N/A")")
                        
                        // EMAIL
                        Text("**Email:** \(user.email ?? "N/A")")
                        
                        // KEYS
                        keysGroup
                        
                        // POSITIONS
                        positionsSection(user: user)
                        
                        // CHAIR COUNT (for testing)
//                        chairCountsSection(user: user)
                    }
                    
                    Section() {
                        // ADMIN LINK
                        if isAdmin {
                            NavigationLink(destination: AdminView()) {
                                HStack {
                                    Text("Admin Panel")
                                }
                            }
                        }
                    }
                    
                    // CLOCK IN/OUT
                    clockInSection(user: user)
                }
            }
        }
        .navigationTitle("Profile")
        .onAppear {
            AdminManager.shared.checkIfUserIsAdmin { isAdminResult in
                DispatchQueue.main.async {
                    self.isAdmin = isAdminResult
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink{
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                    .font(.headline)}
            }
        }.task {
            try? await viewModel.loadCurrentUser()
        }
    }
    
    private func profileTitleSection(user: DBUser) -> some View {
        // profile pic section
        return Section {
            HStack {
                // photo url
                if let photoURL = user.photoURL {
                    AsyncImage(url: URL(string: photoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            // Loaded image
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                                .clipShape(Circle())
                        default:
                            // Placeholder content for loading state
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                                .clipShape(Circle())
                        }
                    }
                }
                
                // user name
                Text(user.fullName ?? "N/A")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.top, 10.0)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    private var keysGroup: some View {
        DisclosureGroup(isExpanded: $keySetExpanded) {
            ForEach(viewModel.keyTypeCodeMap.sorted(by: { $0.key < $1.key }), id: \.key) { keyValuePair in
                let (keyTypeId, keyCode) = keyValuePair
                Text("\(keyTypeId): \(keyCode)")
            }
        } label: {
            Text("**Key Set:** \(viewModel.keySet?.name ?? "N/A")")
        }
    }
    
    private func clockInSection(user: DBUser) -> some View {
        // if user has clock in status
        if let clockedIn = user.isClockedIn {
            // create button
            let result = Section {
                Button {
                    viewModel.toggleClockInStatus()
                } label: {
                    Text(clockedIn ? "Clock Out" : "Clock In")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
            }.listRowBackground(clockedIn ? Color.red : Color.green)
            
            return AnyView(result)
        }
        return AnyView(EmptyView())
    }
    
    private func positionsSection(user: DBUser) -> some View {
        VStack {
            Text("**Positions**: \((user.positions ?? []).joined(separator: ", "))")
                .frame(maxWidth: .infinity, alignment: .leading)
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
                    .buttonStyle(.borderedProminent)
                    // green if user already has position, red otherwise
                    .tint(userHasPosition(text: string) ? .green : .red)
                }
                
                Spacer()
            }
        }
    }
    
    private func chairCountsSection(user: DBUser) -> some View {
        Button {
            if user.chairReport == nil {
                viewModel.addChairReport()
            } else {
                viewModel.removeChairReport()
            }
        } label: {
            Text("**Chair Count:** \(user.chairReport?.chairType ?? "N/A") - \(user.chairReport?.chairCount != nil ? String(user.chairReport!.chairCount) : "N/A")")
        }
    }
}
    
#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
