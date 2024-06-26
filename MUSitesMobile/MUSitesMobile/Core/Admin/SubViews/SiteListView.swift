//
//  SiteListView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 3/29/24.
//

import Foundation
import SwiftUI
import Firebase

//this is purely for the admin view, I wanted to get the list of sites from the siteManager file but this just worked better 
struct SiteListView: View {
    //for sites
    @State private var sites: [Site] = []
    //for inventory
    @State private var InventorySites: [InventorySite] = []
    //for buildings
    @State private var Buildings: [Building] = []
    @State private var isLoading = true
    @State private var error: Error?
    @State private var isDeleteMode = false
    
    @State private var filter: SiteFilter = .sites
    @State private var currentFilter: SiteFilter?
    
    enum SiteFilter: String, CaseIterable {
        case sites = "Sites"
        case inventory = "Inventory Sites"
        case buildings = "Buildings"
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
            } else {
                filterPicker
                listSites()
                Spacer()
            }
        }
        .navigationTitle("Select a Site")
        .toolbar {
//            Picker("Filter", selection: $filter) {
//                ForEach(SiteFilter.allCases, id: \.self) { filter in
//                    Text(filter.rawValue).tag(filter)
//                }
//            }
//            .pickerStyle(SegmentedPickerStyle())
        }
        .onChange(of: filter) {
            print("Filter changed to: \(filter)")
            Task {
                await fetchSites()
            }
        }
        .onAppear {
            Task {
                await fetchSites()
                print("Something")
            }
        }
    }
    
    private var filterPicker: some View {
        return Picker("Filter", selection: $filter) {
            ForEach(SiteFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func listSites() -> some View {
        List {
            switch filter {
            case .sites:
                ForEach(sites, id: \.id) { site in
                    NavigationLink(destination: CategoryPickerView(selectedSiteName: site.name ?? "Default", selectedSiteId: site.id, basePath: "Sites")) {
                        Text(site.name ?? "Default")
                    }
                }
            case .inventory:
                ForEach(InventorySites, id: \.id) { site in
                    NavigationLink(destination: CategoryPickerView(selectedSiteName: site.name ?? "Default", selectedSiteId: site.id, basePath: "inventory_sites")) {
                        Text(site.name ?? "Default")
                    }
                }
            case .buildings:
                ForEach(Buildings, id: \.id) { site in
                    NavigationLink(destination: CategoryPickerView(selectedSiteName: site.name ?? "Default", selectedSiteId: site.id, basePath: "buildings")) {
                        Text(site.name ?? "Default")
                    }
                }
            }
        }
    }
    
    private func fetchSites() async {
        do {
            switch filter {
            case .sites:
                sites = try await SitesManager.shared.getAllSites(descending: false)
                print("Fetched sites: \(sites.count)")
                isLoading = false
            case .inventory:
                InventorySites = try await InventorySitesManager.shared.getAllInventorySites(descending: false)
                print("Fetched inventory sites: \(InventorySites.count)")
            case .buildings:
                Buildings = try await BuildingsManager.shared.getAllBuildings(descending: false, group: nil )
                print("Fetched buildings: \(Buildings.count)")
            }
        } catch let fetchError {
            self.error = fetchError
            print("Failed to fetch sites: \(fetchError.localizedDescription)")
        }
    }
}

#Preview {
    NavigationView {
        SiteListView()
    }
}
