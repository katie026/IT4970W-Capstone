//
//  UserIssuesView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 5/2/24.
//

import SwiftUI

struct UserIssuesView: View {
    // Init
    let currentUser: DBUser
    let sites: [Site]
    let users: [DBUser]
    let issueTypes: [IssueType]
    
    // View Model
    @StateObject private var viewModel = IssuesViewModel()
    // View Control
    @State private var selectedResolutionStatus: Bool? = false
    @State private var isLoading = true
    
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
        issueListSection
            .onAppear {
                Task {
                    fetchIssues()
                }
            }
    }
    
    private var content: some View {
        List {
            issueListSection
        }
    }
    
    private var issueListSection: some View {
        Section("Issues: \(viewModel.userIssues.filter { $0.resolved == false }.count)") {
            HStack(alignment: .center) {
                filterByResolutionMenu
                Spacer()
                sortButton
                refreshButton
            }.padding(.vertical, 5)
            
            // message if no issues
            if (sortedIssues.count == 0) {
                Text("You have no \(selectedResolutionStatus != nil ? (selectedResolutionStatus == true ? "resolved" : "unresolved") : "") issues currently assigned.")
                    .foregroundColor(.secondary)
            }
            
            ForEach(sortedIssues, id: \.id) { issue in
                ScrollView(.horizontal) {
                    IssueCellView(issue: issue, sites: sites, users: users, issueTypes: issueTypes)
                }
                .contextMenu {
                    // toggle reoslution status
                    Button () {
                        toggleIssueResolution(issue: issue)
                    } label: {
                        Label(issue.resolved ?? false ? "Unresolve" : "Resolve", systemImage: issue.resolved ?? false ? "xmark.square" : "checkmark.square")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var filterByResolutionMenu: some View {
        Menu {
            Picker("Resolved", selection: $selectedResolutionStatus) {
                Text("True or False").tag(nil as Bool?)
                Text("True").tag(true as Bool?)
                Text("False").tag(false as Bool?)
            }.multilineTextAlignment(.leading)
        } label: { HStack{
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.accentColor, lineWidth: 2)
                .frame(height: 30) // Adjust height as needed
                .overlay(
                    Text("**Resolved:** \(selectedResolutionStatus != nil ? (selectedResolutionStatus == true ? "True" : "False") : "True or False")")
                        .foregroundColor(Color.accentColor)
                )
            Spacer()
        } }
        .frame(maxWidth: 200)
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
            viewModel.swapUserIssuesOrder()
        }) {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 20))
                .padding(.trailing, 10)
        }
    }
    
    func fetchIssues() {
        Task {
            viewModel.getUserIssues(userId: currentUser.id) {
                print("Got \(viewModel.userIssues.count) issues.")
                isLoading = false
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
    UserIssuesView(
        currentUser: DBUser(
            userId: "oeWvTMrqMza2nebC8mImsFOaNVL2",
            studentId: 12572353,
            isAnonymous: false,
            hasAuthentication: true,
            email: "kmjbcw@umsystem.edu",
            fullName: "Katie Jackson",
            photoURL: "https://lh3.googleusercontent.com/a/ACg8ocJxVcI6q24DRgPDw3dz1lVJLowgsgaXiARzj9lMBGxS=s96-c",
            dateCreated: Date(),
            lastLogin: Date(),
            isClockedIn: true,
            positionIds: ["1HujvaLNHtUEs59nTdci", "FYK5L6XdE4YE5kMpDOyr", "xArozhlNGujNsgczkKsr"],
            chairReport: nil),
        sites: [Site(
            id: "BezlCe1ospf57zMdop2z", //ncgvyP2RI3wNvTfSwjM2
            name: "Clark", //A&S
            buildingId: "SvK0cIKPNTGCReVCw7Ln",
            nearestInventoryId: "8xSqb2Gf5nfgf7g5P9PA",
            chairCounts: [ChairCount(count: 3, type: "physics_black")],
            siteTypeId: "Y3GyB3xhDxKg2CuQcXAA",
            hasClock: true,
            hasInventory: true,
            hasWhiteboard: false,
            namePatternMac: "CLARK-MAC-##",
            namePatternPc: "CLARK-PC-##",
            namePatternPrinter: "Clark Printer ##",
            calendarName: "cornell-hall-5-lab",
            siteCaptain: "ezWofRU3EjNXlXey5P446UeQH6B3"
        )],
        users: [
            DBUser(
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
                chairReport: nil
            ),
            DBUser(
                userId: "oeWvTMrqMza2nebC8mImsFOaNVL2",
                studentId: 12572353,
                isAnonymous: false,
                hasAuthentication: true,
                email: "kmjbcw@umsystem.edu",
                fullName: "Katie Jackson",
                photoURL: "https://lh3.googleusercontent.com/a/ACg8ocJxVcI6q24DRgPDw3dz1lVJLowgsgaXiARzj9lMBGxS=s96-c",
                dateCreated: Date(),
                lastLogin: Date(),
                isClockedIn: true,
                positionIds: ["1HujvaLNHtUEs59nTdci", "FYK5L6XdE4YE5kMpDOyr", "xArozhlNGujNsgczkKsr"],
                chairReport: nil)
        ],
        issueTypes: [IssueType(
            id: "zpavvVHHgI3S3qujebnW",
            name: "Classroom Equipment",
            notes: "Classroom equipment not working."
        )]
    )
}
