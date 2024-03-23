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
    
    func loadBuilding(site: Site) async {
        do {
            self.site = try await SitesManager.shared.getSite(siteId: siteId)
            // Load the associated building
            if let buildingId = self.site?.buildingId {
                await loadBuilding(buildingId: buildingId)
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
    
//    func fetchImageURLs(forSite siteName: String) async {
//        let imagePath = "sites/\(siteName)01.jpg"
//        let imageRef = Storage.storage().reference(withPath: imagePath)
//        
//        imageRef.downloadURL { url, error in
//            if let error = error {
//                print("Error getting download URL: \(error.localizedDescription)")
//            } else if let downloadURL = url {
//                print("Successfully fetched image URL: \(downloadURL)")
//                DispatchQueue.main.async {
//                    self.imageURLs = [downloadURL]
//                }
//            }
//        }
//    }
    func fetchSiteSpecificImageURLs(siteName: String) async {
            let siteImagesRef = Storage.storage().reference(withPath: "sites")

            siteImagesRef.listAll { [weak self] (result, error) in
                guard let items = result?.items, error == nil else {
                    print("Error listing images for site \(siteName): \(error!.localizedDescription)")
                    return
                }

                let siteSpecificImages = items.filter { $0.name.contains(siteName) }

                for item in siteSpecificImages {
                    item.downloadURL { url, error in
                        guard let downloadURL = url, error == nil else {
                            print("Error getting download URL for image \(item.name): \(error!.localizedDescription)")
                            return
                        }

                        DispatchQueue.main.async {
                            self?.imageURLs.append(downloadURL)
                        }
                    }
                }
            }
        }

        
    // Add a property to store the fetched URLs
    @Published var imageURLs: [URL] = []
}
