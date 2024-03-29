//
//  ProfileView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/16/24.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State private var isAdmin: Bool = false
    
    // Disclosure Group bools
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
                    // profile pic section
                    Section {
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
                    
                    Section {
                        Text("**ID:** \(user.userId)")
                        
                        // if user has email, display it
                        Text("**Email:** \(user.email ?? "N/A")")
                        
                        DisclosureGroup(isExpanded: $keySetExpanded) {
                            ForEach(viewModel.keyTypeCodeMap.sorted(by: { $0.key < $1.key }), id: \.key) { keyValuePair in
                                let (keyTypeId, keyCode) = keyValuePair
                                Text("\(keyTypeId): \(keyCode)")
                            }
                        } label: {
                            Text("**Key Set:** \(viewModel.keySet?.name ?? "N/A")")
                        }
                        
                        // toggle clock in status
                        Button {
                            print("Toggle time-clock")
                            viewModel.toggleClockInStatus()
                        } label: {
                            Text("**Clocked In:** \((user.isClockedIn ?? false).description.capitalized)")
                        }
                        
                        // add and remove positions from a user
                        VStack {
                            Text("Positions: \((user.positions ?? []).joined(separator: ", "))")
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
                                    .font(.headline)
                                    .buttonStyle(.borderedProminent)
                                    // green if user already has position, red otherwise
                                    .tint(userHasPosition(text: string) ? .green : .red)
                                }
                            }
                        }
                        
                        // change map
                        Button {
                            if user.chairReport == nil {
                                viewModel.addChairReport()
                            } else {
                                viewModel.removeChairReport()
                            }
                        } label: {
                            Text("**Chair Count:** \(user.chairReport?.chairType ?? "N/A") - \(user.chairReport?.chairCount != nil ? String(user.chairReport!.chairCount) : "N/A")")
                        }
                        //opens up a tab that will take the user to the admin view(this is set up correctly)
                        if isAdmin {
                            NavigationLink(destination: AdminView()) {
                                HStack {
                                    Text("Admin Panel")
                                }
                            }
                        }
                    }
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
}
    
//    #Preview {
//        NavigationStack {
//            //        RootView()
//            ProfileView(showSignInView: .constant(false))
//        }
//    }
//included this struct so it would run(wasnt running with the #Preview)
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(showSignInView: .constant(false))
    }
}

