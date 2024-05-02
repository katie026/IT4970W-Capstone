//  SiteReadyEntriesModel.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 4/19/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class SitesReadyEntriesViewModel: ObservableObject {
    @Published var entries: [SiteReadyEntry] = []
    private let db = Firestore.firestore()
    @Published var startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    @Published var endDate = Date()

    func fetchSitesReadyEntries() {
        db.collection("site_ready_entries")
            .whereField("timestamp", isGreaterThanOrEqualTo: startDate)
            .whereField("timestamp", isLessThanOrEqualTo: endDate)
            .getDocuments { [weak self] querySnapshot, error in
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
                        if let timestamp = document["timestamp"] as? Timestamp {
                            decodedEntry.timestamp = timestamp.dateValue()
                        } else {
                            decodedEntry.timestamp = nil
                        }
                        return decodedEntry
                    } catch {
                        print("Error decoding document data: \(error)")
                        return nil
                    }
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
