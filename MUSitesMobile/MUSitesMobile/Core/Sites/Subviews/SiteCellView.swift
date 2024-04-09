//
//  SiteCellView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/29/24.
//

import SwiftUI

struct SiteCellView: View {
    // init
    let site: Site
    
    //TODO: get site group
    @State private var siteGroup: String? // State to hold the site group information
    
    @State private var isFetching = false // State to track if data is being fetched
    var hasComputers = true
    var hasPrinters = true
    
    func getEquipmentInfo() -> Void {
        //TODO: get equipment info
        // query computers collection to see if there is one at this site.id
        // assign hasComputers
        // query printers collection to see if there is one at this site.id
        // assign hasPrinters
    }
    
    //TODO: update to NavigationStack?
    var body: some View {
        NavigationLink(destination: DetailedSiteView(site: site)) {
            HStack(alignment: .center, spacing: 10) {
                // IMAGE
                AsyncImage(url: URL(string: "https://picsum.photos/300")) {image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                .padding(10)
                
                // INFO BLOCK
                VStack(alignment: .leading) {
                    // name and type icons
                    HStack() {
                        // name
                        Text("\(site.name ?? "N/A")")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        // type icons
                        siteFeatureIcons
                        Spacer()
                    }
                    
                    // subtitle
                    HStack {
                        Text("Group Here - \(site.siteType ?? "N/A")")
                        Spacer()
                    }
                    .font(.callout)
                    .foregroundStyle(.secondary)
                }
                .onAppear {
                    // Trigger fetching when view appears
                    if siteGroup == nil && !isFetching {
                        fetchBuilding()
                    }
                }
            }
            .padding(.horizontal, -16)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var siteFeatureIcons: some View {
        HStack(alignment: .center, spacing: 10) {
            if site.hasInventory == true {
                Image(systemName: "cabinet")
                    .foregroundColor(.green)
            }
            
            if hasComputers == true {
                Image(systemName: "desktopcomputer")
                    .foregroundColor(.purple)
            }
            
            if hasPrinters == true {
                Image(systemName: "printer")
                    .foregroundColor(.pink)
            }
            
            if site.hasClock == true {
                Image(systemName: "clock")
                    .foregroundColor(.orange)
            }
            
            if site.hasWhiteboard == true {
                Image(systemName: "rectangle.inset.filled.and.person.filled")
                    .foregroundColor(.blue)
            }
        }.padding(.leading, 5)
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
    SiteCellView(
        site: Site(
            id: "001",
            name: "Naka",
            buildingId: "EBW",
            nearestInventoryId: "Naka",
            chairCounts: [ChairCount(count: 4, type: "black_physics")],
            siteType: "Classroom",
            hasClock: true,
            hasInventory: true,
            hasWhiteboard: true,
            namePatternMac: "NAKA-MAC-##",
            namePatternPc: "NAKA-PC-##",
            namePatternPrinter: "Naka Printer #"
        )
    )
}
