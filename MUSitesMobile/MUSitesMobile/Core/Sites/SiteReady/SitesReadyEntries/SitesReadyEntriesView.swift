//
//  SitesReadyEntriesView.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 4/21/24.
//

import SwiftUI
import FirebaseFirestore

struct SiteReadyEntriesView: View {
    // View Model
    @StateObject private var viewModel = SitesReadyEntriesViewModel()
    // View Control
    @State private var hasLoadedOnce = false
    @State private var isLoading = true
    // sort/filter option
    @State private var searchOption: SiteReadySearchOption = .user
    @State private var optionUpdatedInventory: Bool? = true
    @State private var optionUser: DBUser? = nil
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy HH:mm"
        return formatter
    }()
    
    // sorted list of siteCaptains
    private var sortedSiteReadys: [SiteReady] {
        // default list
        var filteredList = viewModel.siteReadys
        
        // filter by site if selected
        if viewModel.selectedSite.id != "" {
            filteredList = filteredList
                .filter { $0.siteId == viewModel.selectedSite.id }
        }
        
        // if search option requires search bar
        if (searchOption == .user) {
            if optionUser != nil {
                // filter by user as well
                filteredList = filteredList
                    .filter { $0.user ?? "" == optionUser?.id ?? "" }
            }
        }
        
        // return filteredList
        return filteredList
    }

    var body: some View {
        content
            .navigationTitle("Site Ready Entries")
            .onAppear {
                //only really need to load these once per view session
                Task {
                    // get list of sites
                    viewModel.getSites() {
                        // get list of users
                        viewModel.getUsers() {
                            //viewModel.getSupplyTypes()
                            isLoading = false
                        }
                    }
                }
            }
        
//        VStack {
//            DateRangePicker(startDate: $viewModel.startDate, endDate: $viewModel.endDate) {
//                viewModel.fetchSitesReadyEntries()
//            }
//            List(viewModel.entries) { entry in
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("ID: \(entry.id)")
//                    Text("BW Printer Count: \(entry.bwPrinterCount ?? 0)")
//                    Text("Chair Count: \(entry.chairCount ?? 0)")
//                    Text("Color Printer Count: \(entry.colorPrinterCount ?? 0)")
//                    Text("MAC Count: \(entry.macCount ?? 0)")
//                    Text("Missing Chairs: \(entry.missingChairs ?? 0)")
//                    Text("PC Count: \(entry.pcCount ?? 0)")
//                    Text("Comments: \(entry.comments ?? "")")
//                    Text("Computing Site: \(entry.computingSite ?? "")")
//                    Text("Issues: \(entry.issues?.joined(separator: ", ") ?? "")")
//                    Text("Scanner Count: \(entry.scannerCount ?? 0)")
//                    Text("User: \(entry.user ?? "")")
//                    if let timestamp = entry.timestamp {
//                        Text("Timestamp: \(dateFormatter.string(from: timestamp))")
//                    } else {
//                        Text("Timestamp: N/A")
//                    }
//                    // Add more Text views for other properties
//                }
//                .padding(.vertical, 8)
//            }
//            .navigationTitle("Site Ready Entries")
//        }
    }
    
    private var content: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                // Header
                sitePicker.padding([.horizontal, .top])
                datePickers
                searchBar
                // List of SiteReadys
                siteReadyEntryList
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
        HStack {
            DatePicker(
                "Start Date:",
                selection: $viewModel.startDate,
                in: ...viewModel.endDate,
                displayedComponents: [.date]
            ).labelsHidden()
            
            Spacer()
            
            Text("to").padding([.horizontal])
            
            Spacer()
            
            DatePicker(
                "End Date:",
                selection: $viewModel.endDate,
                in: viewModel.startDate...Date(),
                displayedComponents: [.date]
            ).labelsHidden()
        }.padding([.horizontal])
    }
    
    private var searchBar: some View {
        HStack(alignment: .center) {
            Menu {
                Picker("Search Term", selection: $searchOption) {
                    ForEach(SiteReadySearchOption.allCases, id: \.self) { option in
                        Text(option.optionLabel)
                        
                    }
                }.multilineTextAlignment(.leading)
            } label: { HStack{
                Text(searchOption.optionLabel)
                Spacer()
            } }
            .frame(maxWidth: 90)
            
            if searchOption == .user {
                Picker("User", selection: $optionUser) {
                    Text("All").tag(nil as DBUser?)
                    ForEach(viewModel.users, id: \.self) { user in
                        Text("\(user.fullName ?? "No Name") \(user.pawprint != nil ? "(\(user.pawprint!))" : "")")
                            .tag(user as DBUser?)
                    }
                }.multilineTextAlignment(.leading)
            }
            
            Spacer()
        }.padding(.horizontal, 20)
    }
    
    private var siteReadyEntryList: some View {
        List {
            // if entries have not been laoded yet
            if !hasLoadedOnce {
                // prompt user
                Text("Select a site, and reload.")
                    .foregroundColor(.gray)
            // else, if site has been selected, and the siteReadys count is still 0
            } else if (hasLoadedOnce && viewModel.siteReadys.count == 0) {
                // tell user there are no siteReadys
                Text("There are no site ready entries at \(viewModel.selectedSite.name ?? "this site") between these dates.")
                    .foregroundColor(.gray)
            }
            //TODO: cell view
            ForEach(sortedSiteReadys) { siteReady in
                ScrollView (.horizontal) {
                    NavigationLink(destination: SiteReadyDetailedView(siteReady: siteReady, sites: viewModel.sites, users: viewModel.users, supplyTypes: viewModel.supplyTypes, allIssues: viewModel.issues, allSupplyRequests: viewModel.supplyRequests)) {
                        SiteReadyCellView(siteReady: siteReady, sites: viewModel.sites, users: viewModel.users, supplyTypes: viewModel.supplyTypes, allIssues: viewModel.issues, allSupplyRequests: viewModel.supplyRequests)
                    }.buttonStyle(.plain)
                }
            }
        }
    }
    
    private var refreshButton: some View {
        Button(action: {
            isLoading = true
            fetchSiteReadys()
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
    
    func fetchSiteReadys() {
        Task {
            if viewModel.selectedSite.id != "" {
                viewModel.getSiteReadys(siteId: viewModel.selectedSite.id) {
                    print("Got \(viewModel.siteReadys.count) siteReadys.")
                    viewModel.getIssues() {
//                        viewModel.getSupplyRequests() {
                            isLoading = false
//                        }
                    }
                }
            } else {
                viewModel.getSiteReadys(siteId: nil) {
                    print("Got \(viewModel.siteReadys.count) siteReadys.")
                    viewModel.getIssues() {
//                        viewModel.getSupplyRequests() {
                            isLoading = false
//                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        SiteReadyEntriesView()
    }
}
