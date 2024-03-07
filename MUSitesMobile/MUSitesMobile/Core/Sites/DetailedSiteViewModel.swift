//
//  DetailedSiteViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/5/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class DetailedSiteViewModel: ObservableObject {
    @Published var site: Site?
    @Published var building: Building?
    
    func loadSite(siteId: String) async {
        do {
            self.site = try await SitesManager.shared.getSite(siteId: siteId)
            // Load the associated building
            if let buildingId = self.site?.buildingId {
                try await loadBuilding(buildingId: buildingId)
            }
        } catch {
            print("Error loading site: \(error.localizedDescription)")
            // Handle the error, e.g., show an alert or update the UI accordingly
        }
    }

    func loadBuilding(buildingId: String) async {
        do {
            self.building = try await BuildingsManager.shared.getBuilding(buildingId: buildingId)
        } catch {
            print("Error loading building: \(error.localizedDescription)")
            // Handle the error, e.g., show an alert or update the UI accordingly
        }
    }
}
