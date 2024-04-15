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
    var building: Building?
    var siteType: SiteType?
    var siteGroup: SiteGroup?
    
    @Published var imageURLs: [URL] = []
    @Published var boardImageURLs: [URL] = []
    @Published var inventoryImageURLs: [URL] = []
    @Published var profilePicture: [URL] = []
    
    func loadBuilding(site: Site, completion: @escaping () -> Void) {
        Task {
            do {
                self.building = try await BuildingsManager.shared.getBuilding(buildingId: site.buildingId ?? "")
                completion()
            } catch {
                print("Error loading building: \(error.localizedDescription)")
                // Handle the error, e.g., show an alert or update the UI accordingly
            }
        }
    }
    
    func loadSiteType(siteTypeId: String, completion: @escaping () -> Void) {
        Task {
            do {
                self.siteType = try await SiteTypeManager.shared.getSiteType(siteTypeId: siteTypeId)
                completion()
            } catch {
                print("Error loading site type: \(error)")
            }
        }
    }
    
    func loadSiteGroup(siteGroupId: String, completion: @escaping () -> Void) {
        Task {
            do {
                self.siteGroup = try await SiteGroupManager.shared.getSiteGroup(siteGroupId: siteGroupId)
                completion()
            } catch {
                print("Error loading site group: \(error)")
            }
        }
    }

    func fetchSiteSpecificImageURLs(siteName: String, category: String) async {
        // The reference should include the site name and the category (e.g., "Posters").
        let siteCategoryImagesRef = Storage.storage().reference(withPath: "Sites/\(siteName)/\(category)")
        print("Attempting to access image path: Sites/\(siteName)/\(category)")

        do {
            // List all images in the specific site's category folder
            let result = try await siteCategoryImagesRef.listAll()
            let siteSpecificImages = result.items

            for item in siteSpecificImages {
                // Asynchronously get the download URL for each item
                print("Accessing image: \(item.name)")
                let downloadURL = try await item.downloadURL()
                print("Fetched download URL: \(downloadURL)")
                if category == "Posters" {
                    self.imageURLs.append(downloadURL)
                } else if category == "Board" {
                    self.boardImageURLs.append(downloadURL)
                } else if category == "Inventory" {
                    self.inventoryImageURLs.append(downloadURL)
                    print("Appending the downloadURL: \(downloadURL)")
                } else if category == "ProfilePicture" {
                    self.profilePicture.append(downloadURL)
                }
            }
        } catch {
            print("Error listing images for site \(siteName) category \(category): \(error.localizedDescription)")
        }
    }
}
