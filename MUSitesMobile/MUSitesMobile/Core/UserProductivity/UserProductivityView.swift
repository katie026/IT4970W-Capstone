//
//  UserProductivityView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 5/2/24.
//

import SwiftUI

@MainActor
final class UserProductivityViewModel: ObservableObject {
    // User Info
    var allPositions: [Position] = []
    
    func getUserPositions(userPositionIds: [String]) async -> [Position] {
        var userPositions: [Position] = []
        
        do {
            // load all position
            let allPositions = try await PositionManager.shared.getAllPositions(descending: false)
            print("Got \(allPositions.count) allPositions.")
            
            // for position in user's positionIds array
            for positionId in userPositionIds {
                // find position using positionId
                if let position = allPositions.first(where: { $0.id == positionId }) {
                    // add to position list
                    if !userPositions.contains(where: {$0.id == position.id}) {
                        userPositions.append(position)
                        // sort position list
                        userPositions.sort{ $0.positionLevel ?? 0 < $1.positionLevel ?? 0 }
                    }
                }
            }
            print("Got \(userPositions.count) from the positionIds.")
            return userPositions
        } catch {
            print("Error getting allPositions: \(error)")
            return []
        }
    }
}

struct UserProductivityView: View {
    // View Models
    @StateObject private var issuesViewModel = IssuesViewModel()
    @StateObject private var viewModel = UserProductivityViewModel()
    // User
    @State var user: DBUser? = nil
    @State var positions: [Position] = []
    // View Control
    @State var issuesLoading = true
    // Filtering
    @State private var selectedIssueResolution: Bool? = false
    
    var body: some View {
        content
            .navigationTitle("Productivity")
            .onAppear {
                Task {
                    // get current user
                    try await loadCurrentUser(){
                        // load positions
                        Task {
                            if let posIds = user?.positionIds {
                                positions = await viewModel.getUserPositions(userPositionIds: posIds)
                            }
                        }
                        // load users, sites, and issueTypes
                        // only really need to load these once per view session
                        issuesViewModel.getSites(){
                            print("Got \(issuesViewModel.sites.count) sites.")
                            issuesViewModel.getUsers(){
                                print("Got \(issuesViewModel.users.count) users.")
                                issuesViewModel.getIssueTypes(){
                                    print("Got \(issuesViewModel.issueTypes.count) issueTypes.")
                                    issuesLoading = false
                                }
                            }
                        }
                    }
                }
            }
    }
    
    private var content: some View {
//        ScrollView {
//            if issuesLoading {
//                ProgressView()
//            } else {
//                // Subtitle
//                if let currentPosition = positions.max(by: { $0.positionLevel ?? 0 < $1.positionLevel ?? 0 })?.name {
//                    HStack {
//                        Text(currentPosition)
//                            .font(.title2)
//                            .fontWeight(.medium)
//                            .padding(.horizontal)
//                        Spacer()
//                    }
//                }
//                
//                // ISSUES
//                IssuesSection.frame(height: 400)
//                IssuesSection.frame(height: 400)
//            }
//        }.background(Color(UIColor.systemGray6))
        VStack {
            // Subtitle
            if let currentPosition = positions.max(by: { $0.positionLevel ?? 0 < $1.positionLevel ?? 0 })?.name {
                HStack {
                    Text(currentPosition)
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.horizontal)
                    Spacer()
                }
            }
            
            if issuesLoading {
                ProgressView()
            } else {
                ScrollView {
                    // ISSUES
                    IssuesSection.frame(height: 400)
                    IssuesSection.frame(height: 400)
                }
            }
        }.background(Color(UIColor.systemGray6))

    }
    
    private var IssuesSection: some View {
        Section {
            if let user = user {
                UserIssuesView(currentUser: user, sites: issuesViewModel.sites, users: issuesViewModel.users, issueTypes: issuesViewModel.issueTypes)
            }
        }//.frame(height: 400)
    }
    
    private func loadCurrentUser(completion: @escaping () -> Void) async throws {
        Task {
            do {
                // get authData for current user
                let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
                // use authData to get user data from Firestore as DBUser struct
                self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
            } catch {
                print("Error loading current user: \(error)")
            }
            completion()
        }
    }
}

#Preview {
    NavigationView {
        UserProductivityView()
    }
}
