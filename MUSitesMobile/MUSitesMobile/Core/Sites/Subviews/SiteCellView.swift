//
//  SiteCellView.swift
//  MUSitesMobile
//
//  Created by J Kim on 2/29/24.
//

import SwiftUI

struct SiteCellView: View {
    let site: Site
    
    var body: some View {
        NavigationLink(destination: DetailedSiteView(site: site, inventorySite: InventorySite(id: site.nearestInventoryId ?? "", buildingId: site.buildingId, inventoryTypeIds: ["typeId1", "typeId2"]))){
            HStack(alignment: .top) {
                // AsyncImage(url: URL(string: building.thumbnail ?? "")) { image in
                AsyncImage(url: URL(string: "https://i.dummyjson.com/data/products/19/1.jpg")) {image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                
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
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                
            }
        }
    }
}


#Preview {
    SiteCellView(site: Site(id: "001", name: "Naka", buildingId: "EBW", nearestInventoryId: "Naka", chairCounts: [ChairCount(count: 4, type: "black_physics")], hasClock: true, hasInventory: true, hasWhiteboard: true, namePatternMac: "NAKA-MAC-##", namePatternPc: "NAKA-PC-##", namePatternPrinter: "Naka Printer #"))

}
