//  SiteReadyEntriesModel.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 4/19/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a z"
    return formatter
}()

class SitesReadyEntriesViewModel: ObservableObject {
    @Published var entries: [SiteReadyEntry] = []
    private let db = Firestore.firestore()
    
    func fetchSitesReadyEntries() {
        db.collection("site_ready_entries").getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching site ready entries: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found.")
                return
            }
            
            let entries = documents.compactMap { document -> SiteReadyEntry? in
                do {
                    var decodedEntry = try document.data(as: SiteReadyEntry.self)
                    decodedEntry.timestamp = dateFormatter.date(from: document["timestamp"] as? String ?? "")
                    return decodedEntry
                } catch {
                    print("Error decoding document data: \(error)")
                    return nil
                }
            }
            
            //printed decoded entries for debugging
            for entry in entries {
                print("Decoded Entry:")
                print("ID: \(entry.id)")
                print("BW Printer Count: \(entry.bwPrinterCount ?? -1)") // Use -1 as a placeholder if nil
                print("Chair Count: \(entry.chairCount ?? -1)")
                print("Color Printer Count: \(entry.colorPrinterCount ?? -1)")
                
                if let timestamp = entry.timestamp {
                    print("Timestamp: \(dateFormatter.string(from: timestamp))")
                } else {
                    print("Timestamp: nil")
                }
                
                print("User: \(entry.user ?? "Unknown")")
                print("------------------------------------")
            }
            
            DispatchQueue.main.async {
                self.entries = entries
            }
        }
    }
}

struct SiteReadyEntry: Codable, Identifiable {
    let id: String
    let bwPrinterCount: Int?
    let chairCount: Int?
    let colorPrinterCount: Int?
    let comments: String?
    let computingSite: String?
    let issues: [String]?
    let macCount: Int?
    let missingChairs: Int?
    let pcCount: Int?
    let posters: [Poster]?
    let scannerComputers: [String]?
    let scannerCount: Int?
    var timestamp: Date?
    let user: String?

    struct Poster: Codable {
        let posterType: String
        let status: String
    }
}
