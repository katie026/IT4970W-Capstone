//
//  DetailedInventorySiteView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/6/24.
//

import SwiftUI

@MainActor
final class DetailedInventorySiteViewModel: ObservableObject {
    @Published var inventorySite: InventorySite?
    @Published var building: Building?
    
//    func loadSite(siteId: String) async {
//        do {
//            self.site = try await SitesManager.shared.getSite(siteId: siteId)
//            // Load the associated building
//            if let buildingId = self.site?.buildingId {
//                try await loadBuilding(buildingId: buildingId)
//            }
//        } catch {
//            print("Error loading site: \(error.localizedDescription)")
//            // Handle the error, e.g., show an alert or update the UI accordingly
//        }
//    }
//
//    func loadBuilding(buildingId: String) async {
//        do {
//            self.building = try await BuildingsManager.shared.getBuilding(buildingId: buildingId)
//        } catch {
//            print("Error loading building: \(error.localizedDescription)")
//            // Handle the error, e.g., show an alert or update the UI accordingly
//        }
//    }
}

struct DetailedInventorySiteView: View {
    @StateObject private var viewModel = DetailedInventorySiteViewModel()
    
    private var inventorySite: InventorySite

    init(inventorySite: InventorySite) {
        self.inventorySite = inventorySite
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    DetailedInventorySiteView(inventorySite: InventorySite(id: "TzLMIsUbadvLh9PEgqaV", name: "BCC 122", buildingId: "yXT87CrCZCoJVRvZn5DC", inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]))
}
