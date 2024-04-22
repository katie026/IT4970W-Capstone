//
//  IssuesView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/21/24.
//

import SwiftUI

@MainActor
final class IssuesViewModel: ObservableObject {
    
    @Published private(set) var issues: [Issue] = []
    @Published var selectedSort = SortOption.descending
    @Published var startDate = Calendar.current.date(byAdding: .day, value: -365, to: Date())!
    @Published var endDate = Date()
    
    // for labels
    var sites: [Site] = []
    var users: [DBUser] = []
    var issueTypes: [IssueType] = []
    
    func getIssues(completion: @escaping () async -> Void) {
        Task {
            self.issues = try await IssueManager.shared.getAllIssues(descending: selectedSort.sortDescending, startDate: startDate, endDate: endDate)
            await completion()
        }
    }
    
    func swapIssuesOrder() {
        issues.reverse()
    }
    
    func getSites(completion: @escaping () -> Void) {
        Task {
            do {
                self.sites = try await SitesManager.shared.getAllSites(descending: false)
            } catch {
                print("Error fetching computing sites: \(error)")
            }
            completion()
        }
    }
    
    func getUsers() {
        Task {
            do {
                self.users = try await UserManager.shared.getUsersList()
            } catch  {
                print("Error getting users: \(error)")
            }
        }
    }
    
    func getIssueTypes() {
        Task {
            do {
                self.issueTypes = try await IssueTypeManager.shared.getAllIssueTypes(descending: false)
            } catch  {
                print("Error getting issue types: \(error)")
            }
        }
    }
}

struct IssuesView: View {
    // View Model
    @StateObject private var viewModel = IssuesViewModel()
    // View Control
    @State private var hasLoadedOnce = false
    // Track loading status
    @State private var isLoading = true
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter
    }()
    
    var body: some View {
        // Content
        content
            .navigationTitle("Reported Issues")
            .onAppear {
                Task {
                    //only really need to load these once per view session
                    viewModel.getSites{}
                    viewModel.getUsers()
                    viewModel.getIssueTypes()
                }
            }
    }
    
    func fetchIssues() {
        Task {
            // if arrays are empty, populate them
            viewModel.getIssues {
                print("Got \(viewModel.issues.count) issues.")
                isLoading = false
            }
        }
    }
    
    private var content: some View {
        VStack {
            datePickers
            issueList
        }
    }
    
    private var datePickers: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Date Range:")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
                sortButton
                refreshButton
            }.padding([.horizontal, .top])
            
            HStack {
                HStack {
                    DatePicker(
                        "Start Date:",
                        selection: $viewModel.startDate,
                        in: ...viewModel.endDate,
                        displayedComponents: [.date]
                    ).labelsHidden()
                }.padding([.horizontal, .bottom])
                
                Spacer()
                
                Text("to").padding([.horizontal, .bottom])
                
                Spacer()
                
                HStack {
                    DatePicker(
                        "End Date:",
                        selection: $viewModel.endDate,
                        in: viewModel.startDate...Date(),
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                }.padding([.horizontal, .bottom])
            }
        }
    }
    
    private var issueList: some View {
        List {
            ScrollView(.horizontal) {
                // if user hasn't loaded issues yet
                if !hasLoadedOnce {
                    Text("Choose a date range and reload.")
                        .foregroundColor(.gray)
                // else, if they have, but there are still no entries
                } else if (hasLoadedOnce && viewModel.issues.count == 0) {
                    Text("There are no issues for this date range.")
                        .foregroundColor(.gray)
                }
                
                ForEach(viewModel.issues, id: \.id) { issue in
                    HStack(alignment: .top) {
                        issueCellView(issue: issue)
                        Spacer()
                    }.padding()
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    
    private var refreshButton: some View {
        Button(action: {
            isLoading = true
            fetchIssues()
            hasLoadedOnce = true
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
    
    private func issueCellView(issue: Issue) -> some View {
        let siteName = viewModel.sites.first { $0.id == issue.siteId }?.name ?? "N/A"
        let userFullName = viewModel.users.first { $0.userId == issue.userSubmitted }?.fullName ?? "N/A"
        
        let view = VStack(alignment: .leading, spacing: 8) {
            HStack {
                // DATE
                Image(systemName: "calendar")
                Text("\(issue.timestamp != nil ? dateFormatter.string(from: issue.timestamp!) : "N/A")")
                // RESOLUTION STATUS
                issueResolvedSection(issue: issue)
                // SITE
                Image(systemName: "mappin.and.ellipse")
                    .padding(.leading,20)
                    .foregroundColor(Color.red)
                Text("\(siteName)")
            }
            HStack {
                // TYPE
                issueTypeSection(issue: issue)
                // USER
                Image(systemName: "person.fill")
                Text("\(userFullName)")
            }
            // DESCRIPTION
            //TODO: consider shortening description if it's a certain amount of characters and redirect to a detailed view (or trigger pop up/long hold etc.)
            // if description is not nil
            if let description = issue.description {
                // and is not empty
                if description != "" {
                    // show description section
                    HStack {
                        Image(systemName: "bubble")
                        Text("\(description)")
                    }
                }
            }
        }
        
        return AnyView(view)
    }
    
    private func issueTypeSection(issue: Issue) -> some View {
        let typeName = viewModel.issueTypes.first { $0.id == issue.issueType }?.name ?? "N/A"
        
        // default accent color
        var issueTypeAccentColor = Color.gray
        // default image
        var issueTypeImageName = "square.dotted"
        
        // customize color and image based on Type
        if let issueType = issue.issueType {
            if issueType == "FldaGVfpPdQ57H7XsGOO" { // Chair
                issueTypeAccentColor = Color.green
                issueTypeImageName = "chair"
            } else if issueType == "zpavvVHHgI3S3qujebnW" { // Classroom Equip
                issueTypeAccentColor = Color.orange
                issueTypeImageName = "videoprojector"
            } else if issueType == "GxFGSkbDySZmdkCFExt9" { // Label
                issueTypeAccentColor = Color.purple
                issueTypeImageName = "tag"
            } else if issueType == "wYJWtaj33rx4EIh6v9RY" { // Poster
                issueTypeAccentColor = Color.blue
                issueTypeImageName = "doc.richtext"
            } else if issueType == "r6jx5SXc0x2OC7bM8XNN" { // SitesTech
                issueTypeAccentColor = Color.yellow
                issueTypeImageName = "hammer.fill"
            }
        }
        
        // return section
        return HStack {
            Image(systemName: issueTypeImageName)
                .foregroundColor(issueTypeAccentColor)
            Text("\(typeName)")
                .padding(.vertical, 3)
                .padding(.horizontal, 5)
                .foregroundColor(issueTypeAccentColor)
                .cornerRadius(8)
        }
    }
    
    private func issueResolvedSection(issue: Issue) -> some View {
        // default accent color
        var resolvedAccentColor = Color.gray
        // default image
        var resolvedImageName = "square.dotted"
        
        // customize color and image based on Type
        if let resolved = issue.resolved {
            // if resolved
            if resolved == true {
                resolvedAccentColor = Color.green
                resolvedImageName = "checkmark.circle"
            // if not resolved
            } else {
                resolvedAccentColor = Color.red
                resolvedImageName = "xmark.app"
            }
        }
        
        // return section
        return HStack {
            Image(systemName: resolvedImageName)
                .foregroundColor(resolvedAccentColor)
                .padding(.leading, 15)
            if let resolved = issue.resolved {
                Text(resolved ? "Resolved" : "Unresolved")
                    .padding(.vertical, 3)
                    .padding(.horizontal, 5)
            } else {
                Text("N/A")
                    .padding(.vertical, 3)
                    .padding(.horizontal, 5)
            }
        }
    }
}

#Preview {
    NavigationView {
        IssuesView()
    }
}
