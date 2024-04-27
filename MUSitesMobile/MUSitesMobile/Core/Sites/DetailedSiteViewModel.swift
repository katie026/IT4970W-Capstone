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
    
    //getting siteSpecific computers
    @Published var pcComputers = [Computer]()
    @Published var macComputers = [Computer]()
    private var db = Firestore.firestore()
    
    //getting siteSpecific printers
    @Published var bwPrinters = [Printer]()
    @Published var colorPrinters = [Printer]()
    
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
        Task {
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
    
    // Fetching URLs for images related to a specific site from the Posters category
     func fetchSiteSpecificPosters(siteId: String) async {
         // Firestore references to the necessary collections
         let postersRef = Firestore.firestore().collection("posters")
         let posterTypesRef = Firestore.firestore().collection("poster_types")

         do {
             // Query posters that are linked to the specific site
             let querySnapshot = try await postersRef.whereField("computing_site", isEqualTo: siteId).getDocuments()
             for document in querySnapshot.documents {
                 let posterData = document.data()

                 // Ensure there's a poster_type ID to lookup in the poster_types collection
                 guard let posterTypeId = posterData["poster_type"] as? String else { continue }
                 let posterTypeDoc = try await posterTypesRef.document(posterTypeId).getDocument()
                 if let posterTypeData = posterTypeDoc.data(),
                    let imageName = posterTypeData["image"] as? String {
                     // Construct the path to the image in the Posters folder
                     let imagePath = "Posters/\(imageName)"
                     let imageRef = Storage.storage().reference(withPath: imagePath)

                     // Retrieve the download URL
                     let downloadURL = try await imageRef.downloadURL()
                     print("Fetched download URL: \(downloadURL)")
                     self.imageURLs.append(downloadURL)
                 }
             }
         } catch {
             print("Error fetching posters for site \(siteId): \(error.localizedDescription)")
         }
     }
 
    //fetching the site related computers
    func fetchComputers(forSite siteID: String, withName siteName: String) {
        let capitalizedSiteName = siteName.uppercased()
        //fetch PCs
        db.collection("computers")
            .whereField("computing_site", isEqualTo: siteID)
            .whereField("computer_name", isGreaterThanOrEqualTo: "\(capitalizedSiteName)-PC-")
            .whereField("computer_name", isLessThanOrEqualTo: "\(capitalizedSiteName)-PC-~")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                //creating an array of Computer objects
                self.pcComputers = documents.compactMap { doc -> Computer? in
                    let data = doc.data()
                    let id = doc.documentID
                    guard let name = data["computer_name"] as? String else { return nil }
                    let lastCleaned = (data["last_cleaned"] as? Timestamp)?.dateValue()
                    return Computer(id: id, name: name, lastCleaned: lastCleaned)
                }
            }
        //fetch Macs
        db.collection("computers")
            .whereField("computing_site", isEqualTo: siteID)
            .whereField("computer_name", isGreaterThanOrEqualTo: "\(capitalizedSiteName)-MAC-")
            .whereField("computer_name", isLessThanOrEqualTo: "\(capitalizedSiteName)-MAC-~")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                //creating an array of Computer objects
                self.macComputers = documents.compactMap { doc -> Computer? in
                    let data = doc.data()
                    let id = doc.documentID
                    guard let name = data["computer_name"] as? String else { return nil }
                    let lastCleaned = (data["last_cleaned"] as? Timestamp)?.dateValue()
                    return Computer(id: id, name: name, lastCleaned: lastCleaned)
                }
            }
    }
    //getting the computer names
    private func extractComputerNames(from querySnapshot: QuerySnapshot?) -> [String] {
        guard let documents = querySnapshot?.documents else {
            print("No documents")
            return []
        }
        
        return documents.compactMap { queryDocumentSnapshot -> String? in
            let data = queryDocumentSnapshot.data()
            return data["computer_name"] as? String
        }
    }
    
    func fetchPrinters(forSite siteID: String) {
        let printerCollection = db.collection("printers")
        //B&W printers
        printerCollection
            .whereField("computing_site", isEqualTo: siteID)
            .whereField("type", isEqualTo: "B&W")
            .addSnapshotListener { querySnapshot, error in
                //creating an array of Printer objects
                self.bwPrinters = querySnapshot?.documents.compactMap { doc -> Printer? in
                    let data = doc.data()
                    let id = doc.documentID
                    guard let name = data["name"] as? String else { return nil }
                    return Printer(id: id, name: name, type: "B&W")
                } ?? []
            }
        
        //Color printers
        printerCollection
            .whereField("computing_site", isEqualTo: siteID)
            .whereField("type", isEqualTo: "Color")
            .addSnapshotListener { querySnapshot, error in
                //creating an array of Printer objects
                self.colorPrinters = querySnapshot?.documents.compactMap { doc -> Printer? in
                    let data = doc.data()
                    let id = doc.documentID
                    guard let name = data["name"] as? String else { return nil }
                    return Printer(id: id, name: name, type: "Color")
                } ?? []
            }
    }
}
