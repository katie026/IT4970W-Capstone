//
//  HourlyCleaningsView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/18/24.
//

import SwiftUI

@MainActor
final class HourlyCleaningsViewModel: ObservableObject {
    // hourly cleanings list
    @Published var hourlyCleanings: [HourlyCleaning] = []
    // reference lists
    @Published var sites: [Site] = []
    var users: [DBUser] = []
    var computers: [Computer] = []
    // query info
    @Published var startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @Published var endDate = Date()
    @Published var selectedSort = SortOption.descending
    @Published var selectedSite: Site = Site(id: "", name: "any site", buildingId: "", nearestInventoryId: "", chairCounts: [ChairCount(count: 0, type: "")], siteTypeId: "", hasClock: false, hasInventory: false, hasWhiteboard: false, hasPosterBoard: false, namePatternMac: "", namePatternPc: "", namePatternPrinter: "", calendarName: "")
    
    func swapHourlyCleaningsOrder() {
        hourlyCleanings.reverse()
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
    
    func getHourlyCleanings(siteId: String?, completion: @escaping () -> Void) {
        Task {
            if let siteId {
                do {
                    self.hourlyCleanings = try await HourlyCleaningManager.shared.getAllHourlyCleanings(dateDescending: selectedSort.sortDescending, siteId: siteId, startDate: startDate, endDate: endDate)
                } catch {
                    print("Error fetching hourlyCleanings: \(error)")
                }
                completion()
            } else {
                do {
                    self.hourlyCleanings = try await HourlyCleaningManager.shared.getAllHourlyCleanings(dateDescending: selectedSort.sortDescending, siteId: nil, startDate: startDate, endDate: endDate)
                } catch {
                    print("Error fetching hourlyCleanings: \(error)")
                }
                completion()
            }
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
    
    func getComputers(completion: @escaping () -> Void) {
        Task {
            do {
                self.computers = try await ComputerManager.shared.getAllComputers(descending: false, siteId: nil)
            } catch {
                print("Error fetching computers: \(error)")
            }
            completion()
        }
    }
}

struct HourlyCleaningsView: View {
    // View Model
    @StateObject private var viewModel = HourlyCleaningsViewModel()
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
            .navigationTitle("Hourly Cleanings")
            .onAppear {
                //only really need to load these once per view session
                Task {
                    // get list of sites
                    viewModel.getSites() {
                        // get list of users
                        viewModel.getUsers{
                            print("Got \(viewModel.users.count) users.")
                            // get list of all computers
                            viewModel.getComputers{
                                isLoading = false
                            }
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
                
                // List of HourlyCleanings
                hourlyCleaningList
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
            )
            .labelsHidden()
        }.padding([.horizontal])
    }
    
    private var hourlyCleaningList: some View {
        List {
            // if entries have not been laoded yet
            if !hasLoadedOnce {
                // prompt user
                Text("Select a site, and reload.")
                    .foregroundColor(.gray)
            // else, if site has been selected, and the hourlyCleaning count is still 0
            } else if (hasLoadedOnce && viewModel.hourlyCleanings.count == 0) {
                // tell user there are no hourlyCleanings
                Text("There are no hourly cleanings at \(viewModel.selectedSite.name ?? "this site") between these dates.")
                    .foregroundColor(.gray)
            }
            
            ForEach(viewModel.hourlyCleanings) { hourlyCleaning in
                HourlyCleaningCellView(hourlyCleaning: hourlyCleaning, sites: viewModel.sites, users: viewModel.users, allComputers: viewModel.computers)
            }
        }
    }
    
    private var refreshButton: some View {
        Button(action: {
            isLoading = true
            fetchHourlyCleanings()
            hasLoadedOnce = true
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20))
        }
    }
    
    private var sortButton: some View {
        Button(action: {
            viewModel.swapHourlyCleaningsOrder()
        }) {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 20))
                .padding(.trailing, 10)
        }
    }
    
    func fetchHourlyCleanings() {
        Task {
            if viewModel.selectedSite.id != "" {
                viewModel.getHourlyCleanings(siteId: viewModel.selectedSite.id) {
                    print("Got \(viewModel.hourlyCleanings.count) hourlyCleanings.")
                    isLoading = false
                }
            } else {
                viewModel.getHourlyCleanings(siteId: nil) {
                    print("Got \(viewModel.hourlyCleanings.count) hourlyCleanings.")
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        HourlyCleaningsView()
    }
}
