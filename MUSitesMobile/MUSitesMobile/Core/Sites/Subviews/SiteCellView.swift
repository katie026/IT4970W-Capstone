//
//  SiteCellView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/29/24.
//

import SwiftUI

struct SiteCellView: View {
    let site: Site
    @State private var siteGroup: String? // State to hold the site group information
    @State private var isFetching = false // State to track if data is being fetched
    
    var body: some View {
        NavigationLink(destination: DetailedSiteView(site: site)) {
            HStack(alignment: .top) {
                // AsyncImage(url: URL(string: building.thumbnail ?? "")) { image in

                VStack(alignment: .leading) {
                    Text("\(site.name ?? "N/A")")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("ID: \(site.id)")
                    Text("\(site.buildingId ?? "N/A")")
                    HStack {
                        if site.hasClock == true {
                            Image(systemName: "clock")
                              .foregroundColor(.orange)
                        }
                        
                        if site.hasInventory == true {
                          HStack {
                              Image(systemName: "cabinet")
                                .foregroundColor(.green)
                          }
                        }
                    }
//                    .padding(.leading, 8)
                }
                .onAppear {
                    // Trigger fetching when view appears
                    if siteGroup == nil && !isFetching {
                        fetchBuilding()
                    }
                }
            }
//            .padding(.horizontal, -18)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Fetch building information associated with the site
    private func fetchBuilding() {
        if let buildingId = site.buildingId {
            isFetching = true
            Task {
                do {
                    // Fetch the building from the BuildingsManager
                    let building = try await BuildingsManager.shared.getBuilding(buildingId: buildingId)
                    // Update the state with the retrieved site group
                    self.siteGroup = building.siteGroup
                    isFetching = false
                } catch {
                    print("Error fetching building: \(error.localizedDescription)")
                    isFetching = false
                }
            }
        }
    }
}

#Preview {
    SiteCellView(site: Site(id: "001", name: "Naka", buildingId: "EBW", nearestInventoryId: "Naka", chairCounts: [ChairCount(count: 4, type: "black_physics")], hasClock: true, hasInventory: true, hasWhiteboard: true, namePatternMac: "NAKA-MAC-##", namePatternPc: "NAKA-PC-##", namePatternPrinter: "Naka Printer #"))
}
