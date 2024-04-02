//
//  DetailedSiteViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/5/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

@MainActor
final class DetailedSiteViewModel: ObservableObject {
    @Published var building: Building?
    @Published var imageURLs: [URL] = []
    @Published var boardImageURLs: [URL] = []
    
    func loadBuilding(site: Site) async {
        do {
            self.building = try await BuildingsManager.shared.getBuilding(buildingId: site.buildingId ?? "")
        } catch {
            print("Error loading building: \(error.localizedDescription)")
            // Handle the error, e.g., show an alert or update the UI accordingly
        }
    }

    func fetchSiteSpecificImageURLs(siteName: String, category: String) async {
        // The reference should include the site name and the category (e.g., "Posters").
        let siteCategoryImagesRef = Storage.storage().reference(withPath: "Sites/\(siteName)/\(category)")

        do {
            // List all images in the specific site's category folder
            let result = try await siteCategoryImagesRef.listAll()
            let siteSpecificImages = result.items

            for item in siteSpecificImages {
                // Asynchronously get the download URL for each item
                let downloadURL = try await item.downloadURL()
                if category == "Posters" {
                    self.imageURLs.append(downloadURL)
                } else if category == "Board" {
                    self.boardImageURLs.append(downloadURL)
                }
            }
        } catch {
            print("Error listing images for site \(siteName) category \(category): \(error.localizedDescription)")
        }
    }
}
