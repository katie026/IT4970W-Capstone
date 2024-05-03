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
    var allComputers: [Computer] = []
    @Published var hourlyCleanings: [HourlyCleaning] = []
    
    func getUserPositions(userPositionIds: [String]) async -> [Position] {
        var userPositions: [Position] = []
        
        do {
            // load all position
            let allPositions = try await PositionManager.shared.getAllPositions(descending: false)
            print("Got \(allPositions.count) positions.")
            
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
            return userPositions
        } catch {
            print("Error getting allPositions: \(error)")
            return []
        }
    }
    
    func getSiteCaptainSites(userId: String) async -> [Site] {
        do {
            return try await SitesManager.shared.getSitesBySiteCaptain(userId: userId)
        } catch {
            print("Error getting site captain sites: \(error)")
            return []
        }
    }
    
    func loadComputers(completion: @escaping () -> Void) {
        Task {
            do {
                self.allComputers = try await ComputerManager.shared.getAllComputers(descending: false, siteId: nil)
            } catch {
                print("Error fetching computers: \(error)")
            }
            print("Got \(allComputers.count) computers.")
            completion()
        }
    }
    
    func loadHourlyCleanings(userId: String, completion: @escaping () -> Void) {
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        Task {
            do {
                self.hourlyCleanings = try await HourlyCleaningManager.shared.getHourlyCleaningsSortedBetweenDatesByUser(userId: userId, startDate: startDate, endDate: Date())
            } catch {
                print("Error fetching hourlyCleanings: \(error)")
            }
            completion()
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
    @State var siteCaptainSites: [Site] = []
    @State var siteCaptainsExpanded = false
    // View Control
    @State var issuesLoading = true
    @State var hourlyCleaningsLoading = true
    // Filtering
    @State private var selectedIssueResolution: Bool? = false
    
    var body: some View {
        content
            .navigationTitle("Productivity")
            .onAppear {
                Task {
                    // get current user
                    try await loadCurrentUser(){
                        if let user = user {
                            // load positions, siteCaptains
                            Task {
                                if let posIds = user.positionIds {
                                    positions = await viewModel.getUserPositions(userPositionIds: posIds)
                                }
                                siteCaptainSites = await viewModel.getSiteCaptainSites(userId: user.id)
                            }
                            // load sites, users, hourly cleanings and issueTypes
                            // only really need to load these once per view session
                            issuesViewModel.getSites(){
                                issuesViewModel.getUsers(){
                                    // load hourly cleaning info
                                    viewModel.loadHourlyCleanings(userId: user.id){
                                        viewModel.loadComputers(){
                                            hourlyCleaningsLoading = false
                                        }
                                    }
                                    // load issue info
                                    issuesViewModel.getIssueTypes(){
                                        issuesLoading = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    private var content: some View {
        VStack {            
            if issuesLoading || hourlyCleaningsLoading {
                ProgressView()
            } else {
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
                
                List {
                    // ISSUES
                    if let user = user {
                        InfoSection()
                        IssuesSection(user: user)
                        HourlyCleaningSection()
                    }
                }
            }
        }.background(Color(UIColor.systemGray6))

    }
    
    private func InfoSection() -> some View {
        return Section("Basic Info") {
            DisclosureGroup(isExpanded: $siteCaptainsExpanded) {
                ForEach(self.siteCaptainSites.sorted(by: { $0.name ?? "" < $1.name ?? "" }), id: \.id) { site in
                    NavigationLink(destination: DetailedSiteView(site: site)) {
                        Text(site.name ?? "No Name")
                    }
                }
            } label: {
                Text("**Site Captains:** \(siteCaptainSites.count)")
            }
        }
    }
    
    private func IssuesSection(user: DBUser) -> some View {
        UserIssuesView(currentUser: user, sites: issuesViewModel.sites, users: issuesViewModel.users, issueTypes: issuesViewModel.issueTypes)
    }
    
    private func HourlyCleaningSection() -> some View {
        return Section("Recent Hourly Cleanings") {
            ForEach(viewModel.hourlyCleanings.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }), id: \.id) { cleaning in
                HourlyCleaningCellView(hourlyCleaning: cleaning, sites: issuesViewModel.sites, users: issuesViewModel.users, allComputers: viewModel.allComputers)
            }
        }
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
