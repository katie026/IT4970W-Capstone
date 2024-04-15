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
    @StateObject private var viewModel = DetailedSiteViewModel()
    @State private var profilePictureUrl: URL?
    
    var body: some View {
        HStack(alignment: .top) {
            ProfileImageView(imageURL: viewModel.profilePicture.first)

            VStack(alignment: .leading) {
                Text("\(building.name ?? "N/A")")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("ID: \(building.id)")
                Text("\(building.siteGroupId ?? "N/A")")
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
            .onAppear {
                Task {
                        // Ensure viewModel has the function fetchSiteSpecificImageURLs defined as async
                        await viewModel.fetchSiteSpecificImageURLs(siteName: building.name ?? "", category: "ProfilePicture")
                    }
            }
            
        }
    }
}

#Preview {
    BuildingCellView(building: Building(id: "001", name: "EBW", address: Address(city: "Columbia", country: "US", state: "MO", street: "1400 Treelane Dr.", zipCode: "65211"), coordinates:GeoPoint(latitude: 1.1, longitude: 2.2) , isLibrary: true, isReshall: true, siteGroupId: "G1"))
}
