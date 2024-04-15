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
    @Published var selectedSite: Site = Site(id: "", name: "None", buildingId: "", nearestInventoryId: "", chairCounts: [ChairCount(count: 0, type: "")], siteTypeId: "", hasClock: false, hasInventory: false, hasWhiteboard: false, hasPosterBoard: false, namePatternMac: "", namePatternPc: "", namePatternPrinter: "", calendarName: "")
    @Published var sites: [Site] = []
    
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
}

struct ComputersView: View {
    // View Model
    @StateObject private var viewModel = ComputersViewModel()
    // Track loading status
    @State private var isLoading = true
    
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
                    refreshButton
                }.padding([.horizontal, .top])
                
                
                // List of Computers
                if let selectedSiteName = viewModel.selectedSite.name {
                    // if site has not been selected yet
                    if selectedSiteName == "None" {
                        // prompt user
                        Text("Select a site, and reload.")
                            .padding(.vertical)
                            .foregroundColor(.gray)
                    // if site has been selected, and the computer count is 0
                    } else if (viewModel.computers.count == 0) {
                        // tell user there are no computers
                        Text("There are no computers at this site.")
                            .padding(.vertical)
                            .foregroundColor(.gray)
                    }
                }
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
    }
    
    private var computerList: some View {
        List {
            ForEach(viewModel.computers) { computer in
                Text(computer.name ?? "N/A")
            }
        }
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
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20))
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
