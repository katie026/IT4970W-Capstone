//
//  IssuesView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/21/24.
//

import SwiftUI

@MainActor
final class IssuesViewModel: ObservableObject {
    
    @Published var issues: [Issue] = []
    @Published var selectedSort = SortOption.descending
    @Published var startDate = Calendar.current.date(byAdding: .day, value: -366, to: Date())!
    @Published var endDate = Date()
    
    // for labels
    var sites: [Site] = []
    var users: [DBUser] = []
    var issueTypes: [IssueType] = []
    
    func getIssues(completion: @escaping () -> Void) {
        Task {
            do {
                self.issues = try await IssueManager.shared.getAllIssues(descending: selectedSort.sortDescending, startDate: startDate, endDate: endDate)
            } catch {
                print("Error getting issues: \(error)")
            }
            completion()
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
    
    func toggleResolutionStatus(issue: Issue) {
        Task {
            do {
                try await IssueManager.shared.toggleIssueResolution(issue: issue)
            } catch {
                print("Error toggling issue resolution: \(error)")
            }
        }
    }
}

struct IssuesView: View {
    // View Model
    @StateObject private var viewModel = IssuesViewModel()
    // View Control
    @State private var searchText = ""
    @State private var hasLoadedOnce = false
    // Track loading status
    @State private var isLoading = true
    // sort/filter option
    @State private var searchOption: IssueSearchOption = .description
    @State private var optionResolved: Bool = false
    @State private var optionIssueType: IssueType? = nil
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter
    }()
    
    // sorted list of issues
    private var sortedIssues: [Issue] {
        // default list is only sorted by dateCreated
        let defaultList = viewModel.issues.sorted { issue1, issue2 in
            guard let date1 = issue1.dateCreated, let date2 = issue2.dateCreated else {
                print("Error sorting issues, \(issue1.id) or \(issue2.id) have nil dateCreated.")
                return false // where dateCreated is nil
            }
            return date1 < date2
        }
        
        // if search option requires search bar
        if (searchOption == .description || searchOption == .userAssigned || searchOption == .userSubmitted || searchOption == .siteName) {
            // if nothing in search bar
            if searchText.isEmpty {
                // sort issues by dateCreated
                return defaultList
            } else {
                // check which search term is selected
                if searchOption == .description {
                    // filter & sort issues by description
                    return viewModel.issues.filter {
                        $0.description?.localizedCaseInsensitiveContains(searchText) ?? false
                    }.sorted { $0.description?.localizedCaseInsensitiveCompare($1.description ?? "") == .orderedAscending }
                } else if searchOption == .userAssigned {
                    var filteredList: [Issue] = []
                    // if searchText is empty, return issues that are unassigned
                    if searchText == "" {
                        return viewModel.issues
                            .filter { $0.userAssigned == nil }
                            .sorted { issue1, issue2 in
                                guard let date1 = issue1.dateCreated, let date2 = issue2.dateCreated else {
                                    print("Error sorting issues, \(issue1.id) or \(issue2.id) have nil dateCreated.")
                                    return false // where dateCreated is nil
                                }
                                return date1 < date2
                            }
                    }
                    
                    // else, filter the list by the user assigned names
                    for issue in viewModel.issues {
                        // for each issue, find the site name and compare to the searchText
                        if let userName = viewModel.users.first(where: { $0.id == issue.userAssigned })?.fullName {
                            if userName.localizedCaseInsensitiveContains(searchText) {
                                filteredList.append(issue)
                            }
                        }
                    }
                    // then sort list by user assigned and return
                    return filteredList.sorted { issue1, issue2 in
                        guard let userName1 = viewModel.users.first(where: { $0.id == issue1.userAssigned })?.fullName, let userName2 = viewModel.users.first(where: { $0.id == issue2.userAssigned })?.fullName else {
                            print("Error sorting issues: cannot find user name for \(issue1.id) or \(issue2.id).")
                            return false
                        }
                        return userName1 < userName2
                    }
                } else if searchOption == .userSubmitted {
                    var filteredList: [Issue] = []
                    // filter list by user submitted
                    for issue in viewModel.issues {
                        // for each issue, find the site name and compare to the searchText
                        if let userName = viewModel.users.first(where: { $0.id == issue.userSubmitted })?.fullName {
                            if userName.localizedCaseInsensitiveContains(searchText) {
                                filteredList.append(issue)
                            }
                        }
                    }
                    // sort list by user submitted
                    return filteredList.sorted { issue1, issue2 in
                        guard let userName1 = viewModel.users.first(where: { $0.id == issue1.userSubmitted })?.fullName, let userName2 = viewModel.users.first(where: { $0.id == issue2.userSubmitted })?.fullName else {
                            print("Error sorting issues: cannot find user name for \(issue1.id) or \(issue2.id).")
                            return false
                        }
                        return userName1 < userName2
                    }
                } else if searchOption == .siteName {
                    var filteredList: [Issue] = []
                    // filter list by site name
                    for issue in viewModel.issues {
                        // for each issue, find the site name and compare to the searchText
                        if let siteName = viewModel.sites.first(where: { $0.id == issue.siteId })?.name {
                            if siteName.localizedCaseInsensitiveContains(searchText) {
                                filteredList.append(issue)
                            }
                        }
                    }
                    // sort list by site name
                    return filteredList.sorted { issue1, issue2 in
                        guard let siteName1 = viewModel.sites.first(where: { $0.id == issue1.siteId })?.name, let siteName2 = viewModel.sites.first(where: { $0.id == issue2.siteId })?.name else {
                            print("Error sorting issues: cannot find siteName for \(issue1.id) or \(issue2.id).")
                            return false
                        }
                        return siteName1 < siteName2
                    }
                } else {
                    return defaultList
                }
            }
        // if searching by IssueType
        } else if searchOption == .issueType {
            var filteredList = viewModel.issues
            
            // filter issues by issue type & sort by dateCreated
            if optionIssueType != nil {
                filteredList = viewModel.issues
                    .filter { $0.issueTypeId ?? "" == optionIssueType?.id ?? "" }
            }
            
            // take filteredList, sort it, then return
            return filteredList.sorted { issue1, issue2 in
                guard let date1 = issue1.dateCreated, let date2 = issue2.dateCreated else {
                    print("Error sorting issues, \(issue1.id) or \(issue2.id) hae nil dateCreated.")
                    return false // where dateCreated is nil
                }
                return date1 < date2
            }
        // if searching by resolution status
        } else if searchOption == .resolutionStatus {
            var filteredList = viewModel.issues
            
            if optionResolved {
                // filter for resolved issues
                filteredList = viewModel.issues.filter { $0.resolved ?? false == true }
            } else if !optionResolved {
                // filter for unresolved issues
                filteredList = viewModel.issues.filter { $0.resolved ?? false == false }
            }
            
            // take filteredList, sort it, then return
            return filteredList.sorted { issue1, issue2 in
                guard let date1 = issue1.dateCreated, let date2 = issue2.dateCreated else {
                    print("Error sorting issues, \(issue1.id) or \(issue2.id) hae nil dateCreated.")
                    return false // where dateCreated is nil
                }
                return date1 < date2
            }
        // otherwise
        } else {
            // sort issues by dateCreated
            return defaultList
        }
    }
    
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
            searchBar
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
                }.padding(.horizontal)
                
                Spacer()
                
                Text("to").padding(.horizontal)
                
                Spacer()
                
                HStack {
                    DatePicker(
                        "End Date:",
                        selection: $viewModel.endDate,
                        in: viewModel.startDate...Date(),
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                }.padding(.horizontal)
            }
        }
    }
    
    private var searchBar: some View {
        HStack(alignment: .center) {
            Menu {
                Picker("Search Term", selection: $searchOption) {
                    ForEach(IssueSearchOption.allCases, id: \.self) { option in
                        Text(option.optionLabel)
                        
                    }
                }.multilineTextAlignment(.leading)
            } label: { HStack{
                Text(searchOption.optionLabel)
                Spacer()
            } }
            .frame(maxWidth: 100)
            
            if (searchOption == .description || searchOption == .userAssigned || searchOption == .userSubmitted || searchOption == .siteName) {
                TextField("Search", text: $searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            
            if searchOption == .resolutionStatus {
                Picker("Resolved", selection: $optionResolved) {
                    Text("True").tag(true)
                    Text("False").tag(false)
                }.multilineTextAlignment(.leading)
            }
            
            if searchOption == .issueType {
                Picker("Issue Type", selection: $optionIssueType) {
                    Text("Any").tag(nil as IssueType?)
                    ForEach(viewModel.issueTypes, id: \.self) { type in
                        Text(type.name).tag(type as IssueType?)
                    }
                }.multilineTextAlignment(.leading)
            }
            
            Spacer()
        }.padding(.horizontal)
    }
    
    private var issueList: some View {
        List {
            // if user hasn't loaded issues yet
            if !hasLoadedOnce {
                Text("Choose a date range and reload.")
                    .foregroundColor(.gray)
                // else, if they have, but there are still no entries
            } else if (hasLoadedOnce && viewModel.issues.count == 0) {
                Text("There are no issues for this date range.")
                    .foregroundColor(.gray)
            }
            
            ForEach(sortedIssues, id: \.id) { issue in
                ScrollView(.horizontal) {
                        issueCellView(issue: issue)
                }
                .contextMenu {
                    // toggle reoslution status
                    Button (issue.resolved ?? false ? "Unresolve" : "Resolve") {
                        // toggle resolution status in Firestore
                        viewModel.toggleResolutionStatus(issue: issue)
                        // toggle resolution status in view (locally)
                        if let index = viewModel.issues.firstIndex(where: { $0.id == issue.id }) {
                            if issue.resolved != nil {
                                if issue.resolved == true {
                                    viewModel.issues[index].resolved = false
                                } else {
                                    viewModel.issues[index].resolved = true
                                }
                            } else {
                                viewModel.issues[index].resolved = false
                            }
                        }
                    }
                }
            }
        }.listStyle(.insetGrouped)
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
        let userSubmittedName = viewModel.users.first { $0.userId == issue.userSubmitted }?.fullName ?? "N/A"
        let userAssignedName = viewModel.users.first { $0.userId == issue.userAssigned }?.fullName ?? "N/A"
        
        let view = VStack(alignment: .leading, spacing: 8) {
            HStack {
                // DATE
                Image(systemName: "calendar")
                Text("\(issue.dateCreated != nil ? dateFormatter.string(from: issue.dateCreated!) : "N/A")")
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
                // USER ASSIGNED
                if issue.userAssigned == nil || issue.userAssigned == "" {
                    Image(systemName: "person")
                } else {
                    Image(systemName: "person.fill")
                }
                Text("\(userAssignedName)")
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
                        Text("\(userSubmittedName): \(description)")
                    }
                }
            }
        }
        
        return AnyView(view)
    }
    
    private func issueTypeSection(issue: Issue) -> some View {
        let typeName = viewModel.issueTypes.first { $0.id == issue.issueTypeId }?.name ?? "N/A"
        
        // default accent color
        var issueTypeAccentColor = Color.gray
        // default image
        var issueTypeImageName = "square.dotted"
        
        // customize color and image based on Type
        if let issueType = issue.issueTypeId {
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
