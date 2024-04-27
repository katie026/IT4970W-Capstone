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
    @State private var hasComputingSite: Bool = false
    @State private var hasInventorySite: Bool = false
    @State private var siteGroup: SiteGroup? = nil
    
    var body: some View {
        NavigationLink(destination: BuildingDetailView(building: building)) {
            HStack(alignment: .center, spacing: 10) {
                ProfileImageView(imageURL: viewModel.profilePicture.first)
                
                VStack(alignment: .leading) {
                    Text("\(building.name ?? "N/A")")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    subtitleText()
                }
                
                Spacer()
                
                siteIcons
            }
            .background(Color.clear)
            .onAppear {
                Task {
                    // Ensure viewModel has the function fetchSiteSpecificImageURLs defined as async
                    await viewModel.fetchSiteSpecificImageURLs(siteName: building.name ?? "", category: "ProfilePicture")
                    getSiteGroup(){}
                    checkIfSitesInBuilding()
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func subtitleText() -> some View {
        let siteGroupName = siteGroup?.name
        var buildingType = "Other"
        if building.isReshall == true {
            buildingType = "ResHall"
        } else if building.isLibrary == true {
            buildingType = "Library"
        }
            
        let view = Text("\(siteGroupName ?? "N/A") - \(buildingType)")
        return AnyView(view)
    }
    
    private var siteIcons: some View {
        HStack(alignment: .center, spacing: 10) {
            if hasInventorySite {
                Image(systemName: "cabinet")
                    .foregroundColor(.green)
            }
            
            if hasComputingSite {
                Image(systemName: "desktopcomputer")
                    .foregroundColor(.purple)
            }
        }.padding(.leading, 5)
    }
    
    private func checkIfSitesInBuilding() {
        InventorySitesManager.shared.checkIfSitesInBuilding(buildingId: building.id) { result in
            hasInventorySite = result
        }
        SitesManager.shared.checkIfSitesInBuilding(buildingId: building.id) { result in
            hasComputingSite = result
        }
    }
    
    func getSiteGroup(completion: @escaping () -> Void) {
        if let groupId = building.siteGroupId {
            Task {
                do {
                    self.siteGroup = try await SiteGroupManager.shared.getSiteGroup(siteGroupId: groupId)
                    completion()
                } catch {
                    print("Error getting site group: \(error)")
                }
            }
        } else {
            print("No siteGroupId from the building.")
        }
    }
}

#Preview {
    BuildingCellView(building: Building(id: "g7TPHMNpKVv3xciKcfaq", name: "LTC", address: Address(city: "Columbia", country: "US", state: "MO", street: "1400 Treelane Dr.", zipCode: "65211"), coordinates:GeoPoint(latitude: 1.1, longitude: 2.2) , isLibrary: true, isReshall: true, siteGroupId: "LM0MN0spXlHfd2oZSahO"))
}
