//
//  InventorySiteCellView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/6/24.
//

import SwiftUI

struct InventorySiteCellView: View {
    let inventorySite: InventorySite
    
    var body: some View {
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
            
            // TEXT BLOCK
            VStack(alignment: .leading) {
                Text("\(inventorySite.name ?? "N/A")")
                    .font(.headline)
                Text("\(inventorySite.buildingId ?? "")")
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
            .padding([.leading],10)
            
            Spacer()
        }
    }
}

#Preview {
    InventorySiteCellView(inventorySite: InventorySite(id: "TzLMIsUbadvLh9PEgqaV", name: "BCC 122", buildingId: "yXT87CrCZCoJVRvZn5DC", inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]))
}
