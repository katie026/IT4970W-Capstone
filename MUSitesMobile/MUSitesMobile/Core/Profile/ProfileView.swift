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
    // View Control
    @Binding var showSignInView: Bool
    @State private var isLoading: Bool = true
    @State private var isAdmin: Bool = false
    
    // Disclosure Groups
    @State private var keySetExpanded = false
    
    private func userHasPosition(text: String) -> Bool {
        viewModel.user?.positionIds?.contains(text) == true
    }
    
    var body: some View {
        VStack {
            // check if user is loaded
            if isLoading {
                ProgressView()
            } else {
                if let user = viewModel.user {
                    List {
                        // Profile title
                        profileTitleSection(user: user)
                        // Info Section
                        basicInfoSection
                        // Admin Section
                        adminSection
                        // Clock In/Out
                        clockInSection(user: user)
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .onAppear {
            AdminManager.shared.checkIfCurrentUserIsAdmin { isAdminResult in
                DispatchQueue.main.async {
                    self.isAdmin = isAdminResult
                }
            }
            Task {
                try await viewModel.loadCurrentUser(){
                    viewModel.getPositions(){
                        isLoading = false
                    }
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
        }
    }
    
    private var basicInfoSection: some View {
        Section("Basic Information") {
            // STUDENT ID
            Text("**ID:** \(viewModel.user?.studentId.map(String.init) ?? "N/A")")
            // EMAIL
            Text("**Email:** \(viewModel.user?.email ?? "N/A")")
            // KEYS
            keysGroup
            // POSITIONS
            positionsSection()
            // CHAIR COUNT (for testing)
//            chairCountsSection(user: user)
            Text("**Last Login:** \(viewModel.user?.lastLogin?.formatted(.dateTime) ?? "N/A")")
        }
    }
    
    private var adminSection: some View {
        Section("Administrator Access") {
            // ADMIN LINK
            if isAdmin {
                NavigationLink(destination: AdminView()) {
                    HStack {
                        Text("Admin Panel")
                    }
                }
            }
        }
    }
    
    private func positionsSection() -> some View {
        Section() {
            Text("**Positions**: \((viewModel.userPositions.map{$0.nickname ?? ""}).joined(separator: ", "))")
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
