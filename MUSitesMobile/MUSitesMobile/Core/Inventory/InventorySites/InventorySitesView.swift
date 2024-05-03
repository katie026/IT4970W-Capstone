//
//  InventorySitesView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/6/24.
//

import SwiftUI

@MainActor
final class InventorySitesViewModel: ObservableObject {
    @Published private(set) var inventorySites: [InventorySite] = []
    @Published var selectedGroup: SiteGroup? = nil
    @Published var siteName: String?
    @Published var profilePictureURL: URL?
    
    var allSiteGroups: [SiteGroup] = []
    var inventoryTypes: [InventoryType] = []
    var buildings: [Building] = []
    
    func getInventorySites() {
        Task {
            do {
                self.inventorySites = try await InventorySitesManager.shared.getAllInventorySites(descending: false)
                self.inventorySites.sort { $0.name ?? "" < $1.name ?? "" }
            } catch {
                print("Error fetching inventory sites: \(error)")
            }
        }
    }
    
    func swapInventorySitesOrder() {
        inventorySites.reverse()
    }
    
    func getSiteGroups(completion: @escaping () -> Void) {
        Task {
            do {
                self.allSiteGroups = try await SiteGroupManager.shared.getAllSiteGroups(descending: nil)
                allSiteGroups.sort{ $0.name < $1.name }
                completion()
            } catch {
                print("Error getting site groups: \(error)")
            }
        }
    }
    
    func getBuildings(completion: @escaping () -> Void) {
        Task {
            self.buildings = try await BuildingsManager.shared.getAllBuildings(descending: false, group: nil)
            completion()
        }
    }
    
    func updateProfilePictureURL() {
         guard let siteName = siteName else { return }
         let imageName = "\(siteName)_01.jpg" // Assume there's a method to get the right image number if needed
         let path = "Inventory Sites/\(siteName)/profilePicture/\(imageName)"
         profilePictureURL = URL(string: "https://storage.googleapis.com/path/to/firebase/storage/\(path)")
     }
}

struct InventorySitesView: View {
    // View Model
    @StateObject private var viewModel = InventorySitesViewModel()
    
    // Search Text
    @State private var searchText: String = ""
    
    var filteredInventorySites: [InventorySite] {
        let selectedGroupId = viewModel.selectedGroup?.id
        
        if searchText.isEmpty {
            if selectedGroupId != nil {
                return viewModel.inventorySites
                    .filter { site in
                        let building = viewModel.buildings.first(where: { $0.id == site.buildingId })
                        if building != nil {
                            return building?.siteGroupId == selectedGroupId
                        } else {
                            return false
                        }
                    }
            } else {
                return viewModel.inventorySites // no filter
            }
        } else {
            if selectedGroupId != nil {
                return viewModel.inventorySites
                    .filter { site in
                        let building = viewModel.buildings.first(where: { $0.id == site.buildingId })
                        if building != nil {
                            return building?.siteGroupId == selectedGroupId
                        } else {
                            return false
                        }
                    }
                    .filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
                    .sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
            } else {
                return viewModel.inventorySites
                    .filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
                    .sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 5) {
                searchBar
                    .frame(width: .infinity)
                Spacer()
                sortButton
            }
            .padding()
            
            List {
                ForEach(filteredInventorySites) { inventorySite in
                    NavigationLink{ DetailedInventorySiteView(inventorySite: inventorySite)} label: {
                        InventorySiteCellView(inventorySite: inventorySite)
                    }
                }
            }
        }
        .navigationTitle("Inventory Sites")
        .onAppear {
            viewModel.getInventorySites()
            viewModel.getSiteGroups(){}
            viewModel.getBuildings(){}
        }
        .toolbar(content: {
            // Filtering
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Site Group: \(viewModel.selectedGroup?.name ?? "All")") {
                    Picker("Site Group", selection: $viewModel.selectedGroup) {
                        Text("All").tag(nil as SiteGroup?)
                        ForEach(viewModel.allSiteGroups, id: \.self) { group in
                            Text(group.name).tag(group as SiteGroup?)
                        }
                    }.multilineTextAlignment(.leading)
                }
            }
        })
    }
        
    private var searchBar: some View {
        TextField("Search", text: $searchText)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
    }
    
    private var sortButton: some View {
        Button(action: {
            viewModel.swapInventorySitesOrder()
        }) {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 20))
        }
    }
}

#Preview {
    NavigationStack {
        InventorySitesView()
    }
}
