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
    @State private var computingSites: [Site] = []
    @State private var inventorySites: [InventorySite] = []
    @State var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                // Combined Sites Section
                List {
                    Section(header: Text("Sites")) {
                        ForEach(computingSites) { site in
                            SiteCellView(site: site)
                        }
                    }
                    Section(header: Text("Inventory Sites")) {
                        ForEach(inventorySites) { site in
                            Button {
                                path.append(Route.detailedInventorySite(site))
                            } label: {
                                InventorySiteCellView(inventorySite: site)
                            }
                            .buttonStyle(.plain)
                            .navigationDestination(for: Route.self) { view in
                                switch view {
                                case .inventorySitesList:
                                    InventorySitesView()
                                case .detailedInventorySite(let inventorySite): DetailedInventorySiteView(path: $path, inventorySite: inventorySite)
                                case .inventorySubmission(let inventorySite):
                                    InventorySubmissionView(path: $path, inventorySite: inventorySite)
                                        .environmentObject(SheetManager())
                                case .inventoryChange(let inventorySite):
                                    InventoryChangeView(path: $path, inventorySite: inventorySite)
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationTitle(building.name ?? "")
            }
        }
        .onAppear {
            Task {
                do {
                    // Fetch sites for the selected building using SitesManager
                    computingSites = try await SitesManager.shared.getSitesByBuilding(buildingId: building.id)
                    // Fetch inventory sites for the selected building using InventorySitesManager
                    inventorySites = try await InventorySitesManager.shared.getInventorySitesByBuilding(buildingId: building.id)
                } catch {
                    print("Error fetching or filtering sites:", error.localizedDescription)
                    // Handle error if needed
                }
            }
        }
    }
}

#Preview {
    NavigationView {
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
    .navigationTitle("Building")
}
