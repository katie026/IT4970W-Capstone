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
    @Published var building: Building?
    
    func loadBuilding(site: Site) async {
        do {
            self.building = try await BuildingsManager.shared.getBuilding(buildingId: site.buildingId ?? "")
        } catch {
            print("Error loading building: \(error.localizedDescription)")
            // Handle the error, e.g., show an alert or update the UI accordingly
        }
    }
}
