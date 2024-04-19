//
//  ComputersView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/13/24.
//

import SwiftUI

@MainActor
final class ComputersViewModel: ObservableObject {
    @Published var computers: [Computer] = []
    @Published var selectedSite: Site = Site(id: "", name: "any site", buildingId: "", nearestInventoryId: "", chairCounts: [ChairCount(count: 0, type: "")], siteTypeId: "", hasClock: false, hasInventory: false, hasWhiteboard: false, hasPosterBoard: false, namePatternMac: "", namePatternPc: "", namePatternPrinter: "", calendarName: "")
    @Published var sites: [Site] = []
    @Published var selectedSort: ComputerSortOption? = nil
    
    enum ComputerSortOption: String, CaseIterable {
        // CaseIterable so we can loop through them
        case name
        case lastCleaned
        
        var optionString: String {
            switch self {
            case .name: return "Name"
            case .lastCleaned: return "Last Cleaned"
            }
        }
    }
    
    func getComputers(siteId: String?, completion: @escaping () -> Void) {
        Task {
            if let siteId {
                do {
                    self.computers = try await ComputerManager.shared.getAllComputers(descending: false, siteId: siteId)
                } catch {
                    print("Error fetching computers: \(error)")
                }
                completion()
            } else {
                self.computers = try await ComputerManager.shared.getAllComputers(descending: false, siteId: nil)
                completion()
            }
        }
    }
    
    func getSites(completion: @escaping () -> Void) {
        Task {
            self.sites = try await SitesManager.shared.getAllSites(descending: false)
            completion()
        }
    }
    
    func swapComputersOrder() {
        computers.reverse()
    }
    
    func sortComputersByName() {
        computers = computers.sorted { $0.name ?? "" < $1.name ?? ""}
    }
    
    func sortComputersByDate() {
        computers = computers.sorted { computer1, computer2 in
            // Get the dates to compare (use 1/1/2001 as the default date)
            let date1 = computer1.lastCleaned ?? Date(timeIntervalSinceReferenceDate: 0)
            let date2 = computer2.lastCleaned ?? Date(timeIntervalSinceReferenceDate: 0)
            
            // Compare the dates
            return date1 < date2 // descending dates
        }
    }
}

struct ComputersView: View {
    // View Model
    @StateObject private var viewModel = ComputersViewModel()
    // View Control
    @State private var hasLoadedOnce = false
    @State private var isLoading = true
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/d/yy"
        return formatter
    }()
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                // Header
                HStack(alignment: .center) {
                    Text("Computing Site:").fontWeight(.bold)
                    sitePicker
                    Spacer()
                    sortButton
                    refreshButton
                }.padding([.horizontal, .top])
                
                // Computer List
                computerList
            }
        }
        .navigationTitle("Computers")
        .onAppear {
            // get list of sites
            viewModel.getSites() {
                isLoading = false
            }
        }
        .toolbar(content: {
            // Sorting
            ToolbarItem(placement: .navigationBarTrailing) {
                // will be sorted by name by default
                Menu("Sort by: \(viewModel.selectedSort?.optionString ?? "Name")") {
                    ForEach(ComputersViewModel.ComputerSortOption.allCases, id: \.self) { option in
                        Button(option.optionString) {
                            switch option {
                            case .name:
                                viewModel.selectedSort = .name
                                viewModel.sortComputersByName()
                            case .lastCleaned:
                                viewModel.selectedSort = .lastCleaned
                                viewModel.sortComputersByDate()
                            }
                        }
                    }
                }
            }
        })
    }
    
    private var computerList: some View {
        List {
            // if computers have not been laoded yet
            if !hasLoadedOnce {
                // prompt user
                Text("Select a site, and reload.")
                    .foregroundColor(.gray)
                // else, if site has been selected, and the computer count is still 0
            } else if (hasLoadedOnce && viewModel.computers.count == 0) {
                // tell user there are no computers
                Text("There are no computers at \(viewModel.selectedSite.name ?? "this site").")
                    .foregroundColor(.gray)
            } else {
                // loop through computers
                ForEach(viewModel.computers) { computer in
                    computerRow(computer: computer)
                }
            }
        }
    }
    
    private func computerRow(computer: Computer) -> some View {
        var textColor: Color = .primary
        
        if let lastCleaned = computer.lastCleaned {
            let daysSinceLastCleaned = Calendar.current.dateComponents([.day], from: lastCleaned, to: Date()).day ?? 0
            
            switch daysSinceLastCleaned {
            case ...4:
                textColor = .primary // cleaned within 4 days
            case 5...6:
                textColor = .yellow // cleaned between 5-6 days
            case 7...14:
                textColor = .orange // cleaned between 1-2 weeks
            case 15...:
                textColor = .red // hasn't been cleaned in over 2 weeks
            default:
                textColor = .primary
            }
        }
        
        let result = VStack(alignment: .leading) {
//            Text("Last Cleaned: \(computer.lastCleaned != nil ? dateFormatter.string(from: computer.lastCleaned!) : "N/A")")
//                .font(.system(size: 12))
//                .padding(.top, 1)
            
            // COMPUTER NAME
            Text(computer.name ?? "N/A")
            
            // LAST CLEANED
            if let lastCleaned = computer.lastCleaned {
                Text("Last Cleaned: \(dateFormatter.string(from: lastCleaned))")
                    .font(.system(size: 12))
                    .foregroundColor(textColor)
                    .padding(.top, 1)
            } else {
                Text("Last Cleaned: N/A")
                    .font(.system(size: 12))
                    .foregroundColor(textColor)
                    .padding(.top, 1)
            }
        }.padding(.vertical, 1)
        
        return AnyView(result)
    }
    
    private var sitePicker: some View {
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
    }
    
    private var refreshButton: some View {
        Button(action: {
            isLoading = true
            fetchComputers()
            hasLoadedOnce = true
            viewModel.selectedSort = .name
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20))
        }
    }
    
    private var sortButton: some View {
        Button(action: {
            viewModel.swapComputersOrder()
        }) {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 20))
                .padding(.trailing, 10)
        }
    }
    
    func fetchComputers() {
        Task {
            if viewModel.selectedSite.id != "" {
                viewModel.getComputers(siteId: viewModel.selectedSite.id) {
                    print("Got \(viewModel.computers.count) computers.")
                    isLoading = false
                }
            } else {
                viewModel.getComputers(siteId: nil) {
                    print("Got \(viewModel.computers.count) computers.")
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ComputersView()
    }
}
