//
//  InventorySiteCellView.swift
//  MUSitesMobile
//
//  Created by J Kim on 3/6/24.
//

import SwiftUI

struct InventorySiteCellView: View {
    let inventorySite: InventorySite
    
    var body: some View {
        NavigationLink(destination: DetailedInventorySiteView(inventorySite: inventorySite)) {
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
                    Text("\(inventorySite.name ?? "N/A")")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("ID: \(inventorySite.id)")
                    Text("\(inventorySite.buildingId ?? "N/A")")
                    HStack {
                        if inventorySite.inventoryTypeIds?.count ?? 0 > 0 {
                            Text("has tyepIds")
                                .font(.callout)
                                .foregroundStyle(.orange)
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
    InventorySiteCellView(inventorySite: InventorySite(id: "TzLMIsUbadvLh9PEgqaV", name: "BCC 122", buildingId: "yXT87CrCZCoJVRvZn5DC", inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]))
}
