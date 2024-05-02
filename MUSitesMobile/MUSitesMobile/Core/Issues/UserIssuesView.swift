//
//  UserIssuesView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 5/2/24.
//

import SwiftUI

struct UserIssuesView: View {
    // View Model
    @StateObject private var viewModel = IssuesViewModel()
    // View Control
    @State private var selectedResolutionStatus: Bool? = nil
    @State private var isLoading = true
    // Current User
    @State private(set) var user: DBUser? = nil
    
    // sorted list of issues
    private var sortedIssues: [Issue] {
        if selectedResolutionStatus != nil {
            return viewModel.userIssues
                .filter { $0.resolved ?? false == selectedResolutionStatus }
        } else {
            return viewModel.userIssues
        }
    }
    
    var body: some View {
        content
            .onAppear {
                Task {
                    //only really need to load these once per view session
                    viewModel.getSites{}
                    viewModel.getUsers()
                    viewModel.getIssueTypes()
                    try await loadCurrentUser() {
                        fetchIssues()
                    }
                }
            }
    }
    
    private var content: some View {
        VStack {
            issueList
        }
    }
    
    private var issueList: some View {
        List() {
            // if user hasn't loaded issues yet
            if (viewModel.userIssues.count == 0) {
                Text("You have no issues currently assigned.")
                    .foregroundColor(.gray)
            }
            
            ForEach(sortedIssues, id: \.id) { issue in
                ScrollView(.horizontal) {
                    IssueCellView(issue: issue, sites: viewModel.sites, users: viewModel.users, issueTypes: viewModel.issueTypes)
                }
                .contextMenu {
                    // toggle reoslution status
                    Button (issue.resolved ?? false ? "Unresolve" : "Resolve") {
                        toggleIssueResolution(issue: issue)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                filterByResolutionMenu
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                refreshButton
            }
        }
    }
    
    private var filterByResolutionMenu: some View {
        Menu {
            Picker("Resolved", selection: $selectedResolutionStatus) {
                Text("True or False").tag(nil as Bool?)
                Text("True").tag(true as Bool?)
                Text("False").tag(false as Bool?)
            }.multilineTextAlignment(.leading)
        } label: { HStack{
            Text("Resolved: \(selectedResolutionStatus.map { String($0) } ?? "True or False")")
            Spacer()
        } }
        .frame(maxWidth: 100)
    }
    
    private var refreshButton: some View {
        Button(action: {
            isLoading = true
            fetchIssues()
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20))
        }
    }
    
    private var sortButton: some View {
        Button(action: {
            viewModel.swapIssuesOrder()
        }) {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 20))
                .padding(.trailing, 10)
        }
    }
    
    func loadCurrentUser(completion: @escaping () -> Void) async throws {
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
    
    func fetchIssues() {
        Task {
            if let currentUser = user {
                viewModel.getUserIssues(userId: currentUser.id) {
                    print("Got \(viewModel.userIssues.count) issues.")
                    isLoading = false
                }
            }
        }
    }
    
    func toggleIssueResolution(issue: Issue) {
        // toggle resolution status in Firestore
        viewModel.toggleResolutionStatus(issue: issue)
        // toggle resolution status in view (locally)
        if let index = viewModel.userIssues.firstIndex(where: { $0.id == issue.id }) {
            if issue.resolved != nil {
                if issue.resolved == true {
                    viewModel.userIssues[index].resolved = false
                } else {
                    viewModel.userIssues[index].resolved = true
                }
            } else {
                viewModel.userIssues[index].resolved = false
            }
        }
    }
}

#Preview {
    UserIssuesView()
}
