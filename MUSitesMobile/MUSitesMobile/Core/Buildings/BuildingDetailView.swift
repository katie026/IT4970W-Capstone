//
//  BuildingDetailView.swift
//  MUSitesMobile
//
//  Created by Cassandra Beisheim on 4/4/24.
//

import SwiftUI
import FirebaseFirestore

struct BuildingDetailView: View {
    let building: Building
    @State private var filteredSites: [Site] = []
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {
                
                TextField("Search", text: $searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                // Combined Sites Section
                List {
                    Section(header: Text("Sites")) {
                        ForEach(filteredSites) { site in
                            SiteCellView(site: site)
                        }
                    }
                    Section(header: Text("Inventory Sites")) {
                        ForEach(filteredSites.compactMap { $0 as? InventorySite }) { site in
                            InventorySiteCellView(inventorySite: site)
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationTitle(building.name ??
                "")
                
                
            }
        }
        .onAppear {
            Task {
                do {
                    // Fetch sites for the selected building using SitesManager
                    let sites = try await SitesManager.shared.getAllSites(descending: nil)
                    print("All sites fetched:", sites)
                    
                    // Filter sites based on the building ID
                    filteredSites = sites.filter { $0.buildingId == building.id }
                    print("Filtered sites:", filteredSites)
                } catch {
                    print("Error fetching or filtering sites:", error.localizedDescription)
                    // Handle error if needed
                }
            }
        }
    }

    // Filtered and sorted sites based on search text
    private var sortedSites: [Site] {
        if searchText.isEmpty {
            return filteredSites.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
        } else {
            return filteredSites.filter {
                $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
        }
    }
}





#Preview {
    BuildingDetailView(
        building: Building(
            id: "VYUlFVzdSeVTBkNuPQWT",
            name: "Arts & Science",
            address: Address(city: "Columbia", country: "US", state: "MO", street: "1400 Treelane Dr.", zipCode: "65211"),
            coordinates:GeoPoint(latitude: 1.1, longitude: 2.2) ,
            isLibrary: true,
            isReshall: true,
            siteGroupId: "zw1TFIf7KQxMNrThdfD1"
        )
    )
}
