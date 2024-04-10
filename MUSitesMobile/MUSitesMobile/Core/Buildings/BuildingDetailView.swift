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
    @State private var filteredInventorySites: [InventorySite] = []
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {
                Text(building.name ?? "")
                TextField("Search", text: $searchText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)

                // Regular Sites Section
                NavigationView {
                    List {
                        ForEach(filteredSites) { site in
                            SiteCellView(site: site)
                        }
                    }
                    .navigationTitle("Sites")
                }

                // Inventory Sites Section
                NavigationView {
                    List {
                        ForEach(filteredInventorySites) { inventorySite in
                            InventorySiteCellView(inventorySite: inventorySite)
                        }
                    }
                    .navigationTitle("Inventory Sites")
                }
            }
        }
        .onAppear {
            Task {
                do {
                    // Fetch regular sites for the selected building using SitesManager
                    let sites = try await SitesManager.shared.getAllSites(descending: nil)
                    filteredSites = sites.filter { $0.buildingId == building.id }

                    // Fetch inventory sites for the selected building using InventorySitesManager
                    let inventorySites = try await InventorySitesManager.shared.getAllInventorySites(descending: nil)
                    filteredInventorySites = inventorySites.filter { $0.buildingId == building.id }
                } catch {
                    print("Error fetching sites: \(error.localizedDescription)")
                    // Handle error if needed
                }
            }
        }
    }

    // Filtered and sorted regular sites based on search text
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
