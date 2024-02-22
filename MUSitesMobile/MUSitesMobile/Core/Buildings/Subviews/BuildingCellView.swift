//
//  BuildingCellView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/19/24.
//

import SwiftUI
import FirebaseFirestore // for Preview

struct BuildingCellView: View {
    
    let building: Building
    
    var body: some View {
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
                Text("\(building.name ?? "N/A")")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("ID: \(building.id)")
                Text("\(building.siteGroup ?? "N/A")")
                HStack {
                    if building.isReshall == true {
                        Text("ResHall")
                            .font(.callout)
                            .foregroundStyle(.orange)
                    }
                    
                    if building.isLibrary == true {
                        Text("Library")
                            .font(.callout)
                            .foregroundStyle(.green)
                    }
                }
            }
            .font(.callout)
            .foregroundStyle(.secondary)
            
        }
    }
}

#Preview {
    BuildingCellView(building: Building(id: "001", name: "EBW", address: Address(city: "Columbia", country: "US", state: "MO", street: "1400 Treelane Dr.", zipCode: "65211"), coordinates:GeoPoint(latitude: 1.1, longitude: 2.2) , isLibrary: true, isReshall: true, siteGroup: "G1"))
}
