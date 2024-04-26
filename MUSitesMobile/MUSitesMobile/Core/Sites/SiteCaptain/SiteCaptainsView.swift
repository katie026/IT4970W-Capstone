//
//  SiteCaptainsView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/26/24.
//

import SwiftUI

@MainActor
final class SiteCaptainsViewModel: ObservableObject {
    // site captain list
    @Published var siteCaptains: [SiteCaptain] = []
    
    // for labels
    var sites: [Site] = []
    var users: [DBUser] = []
    var issueTypes: [IssueType] = []
    var issues: [Issue] = []
    var supplyTypes: [SupplyType] = []
    var supplyRequests: [SupplyRequest] = []
    
    // query info
    @Published var selectedSort = SortOption.descending
    @Published var startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @Published var endDate = Date()
    @Published var selectedSite: Site = Site(id: "", name: "any site", buildingId: "", nearestInventoryId: "", chairCounts: [ChairCount(count: 0, type: "")], siteTypeId: "", hasClock: false, hasInventory: false, hasWhiteboard: false, hasPosterBoard: false, namePatternMac: "", namePatternPc: "", namePatternPrinter: "", calendarName: "")
    
    func swapEntriesOrder() {
        siteCaptains.reverse()
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
    
    func getUsers(completion: @escaping () -> Void) {
        Task {
            do {
                self.users = try await UserManager.shared.getUsersList()
            } catch  {
                print("Error getting users: \(error)")
            }
            completion()
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
    
    func getSupplyTypes() {
        Task {
            self.supplyTypes = try await SupplyTypeManager.shared.getAllSupplyTypes(descending: false)
        }
    }
    
    func getSiteCaptains(siteId: String?, completion: @escaping () -> Void) {
        Task {
            if let siteId {
                do {
                    self.siteCaptains = try await SiteCaptainManager.shared.getAllSiteCaptains(dateDescending: selectedSort.sortDescending, siteId: siteId, startDate: startDate, endDate: endDate)
                } catch {
                    print("Error fetching siteCaptains: \(error)")
                }
                completion()
            } else {
                do {
                    self.siteCaptains = try await SiteCaptainManager.shared.getAllSiteCaptains(dateDescending: selectedSort.sortDescending, siteId: nil, startDate: startDate, endDate: endDate)                } catch {
                    print("Error fetching siteCaptains: \(error)")
                }
                completion()
            }
        }
    }
    
    func getIssues(completion: @escaping () -> Void) {
        Task {
            do {
                self.issues = []
                for entry in self.siteCaptains {
                    guard let issueIds = entry.issues else {
                        continue }
                    for issueId in issueIds {
                        let issue = try await IssueManager.shared.getIssue(issueId: issueId)
                        self.issues.append(issue)
                    }
                }
            } catch {
                print("Error fetching issues: \(error)")
            }
            print("Got \(self.issues.count) issues.")
            completion()
        }
    }
    
    func getSupplyRequests(completion: @escaping () -> Void) {
        Task {
            do {
                self.supplyRequests = []
                for entry in self.siteCaptains {
                    guard let requestIds = entry.supplyRequests else { continue }
                    for requestId in requestIds {
                        let request = try await SupplyRequestManager.shared.getSupplyRequest(supplyRequestId: requestId)
                        self.supplyRequests.append(request)
                    }
                }
            } catch {
                print("Error fetching supplyRequests: \(error)")
            }
            print("Got \(self.supplyRequests.count) supplyRequests.")
            completion()
        }
    }
}

struct SiteCaptainsView: View {
    // View Model
    @StateObject private var viewModel = SiteCaptainsViewModel()
    // View Control
    @State private var hasLoadedOnce = false
    @State private var isLoading = true
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy HH:mm"
        return formatter
    }()
    
    var body: some View {
        content
            .navigationTitle("Site Captain Entries")
            .onAppear {
                //only really need to load these once per view session
                Task {
                    // get list of sites
                    viewModel.getSites() {
                        // get list of users
                        viewModel.getUsers() {
                            viewModel.getSupplyTypes()
                            isLoading = false
                        }
                    }
                }
            }
    }
    
    private var content: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                // Header
                sitePicker.padding([.horizontal, .top])
                datePickers
                
                // List of SiteCaptains
                siteCaptainEntryList
            }
        }
    }
    
    private var sitePicker: some View {
        HStack(alignment: .center) {
            // Label
            Text("Computing Site:").fontWeight(.bold)
            // Site Picker
            Picker("Computing Site:", selection: $viewModel.selectedSite) {
                // Option for All sites
                Text("All").tag(Site(id: "", name: "All", buildingId: "", nearestInventoryId: "", chairCounts: [ChairCount(count: 0, type: "")], siteTypeId: "", hasClock: false, hasInventory: false, hasWhiteboard: false, hasPosterBoard: false, namePatternMac: "", namePatternPc: "", namePatternPrinter: "", calendarName: ""))
                
                // Options for each site in Site list
                ForEach(viewModel.sites) { site in
                    // dispay the name
                    Text(site.name ?? "N/A").tag(site) // tag associates each Site with itself
                }
            }
            Spacer()
            
            // Buttons
            sortButton
            refreshButton
        }
        
    }
    
    private var datePickers: some View {
        VStack {
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
    
    private var siteCaptainEntryList: some View {
        List {
            // if entries have not been laoded yet
            if !hasLoadedOnce {
                // prompt user
                Text("Select a site, and reload.")
                    .foregroundColor(.gray)
            // else, if site has been selected, and the siteCapatin count is still 0
            } else if (hasLoadedOnce && viewModel.siteCaptains.count == 0) {
                // tell user there are no hourlyCleanings
                Text("There are no site captain entries at \(viewModel.selectedSite.name ?? "this site") between these dates.")
                    .foregroundColor(.gray)
            }
            
            ForEach(viewModel.siteCaptains) { siteCaptain in
                SiteCaptainCellView(siteCaptain: siteCaptain, sites: viewModel.sites, users: viewModel.users, supplyTypes: viewModel.supplyTypes, allIssues: viewModel.issues, allSupplyRequests: viewModel.supplyRequests)
            }
        }
    }
    
    private var refreshButton: some View {
        Button(action: {
            isLoading = true
            fetchSiteCaptains()
            hasLoadedOnce = true
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20))
        }
    }
    
    private var sortButton: some View {
        Button(action: {
            viewModel.swapEntriesOrder()
        }) {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 20))
                .padding(.trailing, 10)
        }
    }
    
    func fetchSiteCaptains() {
        Task {
            if viewModel.selectedSite.id != "" {
                viewModel.getSiteCaptains(siteId: viewModel.selectedSite.id) {
                    print("Got \(viewModel.siteCaptains.count) siteCaptains.")
                    viewModel.getIssues() {
                        viewModel.getSupplyRequests() {
                            isLoading = false
                        }
                    }
                }
            } else {
                viewModel.getSiteCaptains(siteId: nil) {
                    print("Got \(viewModel.siteCaptains.count) siteCaptains.")
                    viewModel.getIssues() {
                        viewModel.getSupplyRequests() {
                            isLoading = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        SiteCaptainsView()
    }
}
