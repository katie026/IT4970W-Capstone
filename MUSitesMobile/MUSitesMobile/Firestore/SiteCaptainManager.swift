//
//  SiteCaptainManager.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/25/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

struct SiteCaptain: Codable {
    let id: String
    let siteId: String?
    let issues: [SiteCaptainIssue]?
    let labelsForReplacement: [String]?
    let suppliesNeeded: [SupplyNeeded]?
    let timestamp: Date?
    let updatedInventory: Bool?
    let user: String?
    
    init(
        id: String,
        siteId:String? = nil,
        issues: [SiteCaptainIssue]? = nil,
        labelsForReplacement:[String]? = nil,
        suppliesNeeded:[SupplyNeeded]? = nil,
        timestampValue : Date? = nil,
        updatedInventory: Bool? = nil,
        user : String? = nil
        
    ) {
        
        self.id = id
        self.siteId = siteId
        self.issues = issues
        self.labelsForReplacement = labelsForReplacement
        self.suppliesNeeded = suppliesNeeded
        self.timestamp = timestampValue
        self.updatedInventory = updatedInventory
        self.user = user
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case siteId = "site_id"
        case issues = "issues"
        case labelsForReplacement = "labels_for_replacement"
        case suppliesNeeded = "supplies_needed"
        case timestamp = "timestamp"
        case updatedInventory = "updated_inventory"
        case user = "user"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.siteId = try container.decodeIfPresent(String.self, forKey: .siteId)
        self.issues = try container.decodeIfPresent([SiteCaptainIssue].self, forKey: .issues)
        self.labelsForReplacement = try container.decodeIfPresent([String].self, forKey: .labelsForReplacement)
        self.suppliesNeeded = try container.decodeIfPresent([SupplyNeeded].self, forKey: .suppliesNeeded)
        self.timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp)
        self.updatedInventory = try container.decodeIfPresent(Bool.self, forKey: .updatedInventory)
        self.user = try container.decodeIfPresent(String.self, forKey: .user)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.siteId, forKey: .siteId)
        try container.encodeIfPresent(self.issues, forKey: .issues)
        try container.encodeIfPresent(self.labelsForReplacement, forKey: .labelsForReplacement)
        try container.encodeIfPresent(self.suppliesNeeded, forKey: .suppliesNeeded)
        try container.encodeIfPresent(self.timestamp, forKey: .timestamp)
        try container.encodeIfPresent(self.updatedInventory, forKey: .updatedInventory)
        try container.encodeIfPresent(self.user, forKey: .user)
    }

}

struct SiteCaptainIssue: Codable {
    let issue: String
    let ticket: String
}

struct SupplyNeeded: Codable {
    let count: Int
    let supply: String
}


class SiteCaptainManager {
    private let db = Firestore.firestore()
    private let siteCaptainEntry = "site_captain_entries"
    private let supplyRequestCollection = "supply_requests"
    
    func submitSiteCaptainEntry(_ computingSite: SiteCaptain, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection(siteCaptainEntry).document(computingSite.id).setData(from: computingSite) { [weak self] error in
                if let error = error {
                    print("Error submitting site captain entry: \(error.localizedDescription)")
                    completion(error)
                } else {
                    print("Site captain entry submitted successfully!")
//                    self?.createSupplyRequests(for: computingSite, completion: completion)
                }
            }
        } catch {
            print("Error encoding site captain entry: \(error.localizedDescription)")
            completion(error)
        }
    }
    
//    private func createSupplyRequests(for computingSite: SiteCaptain, completion: @escaping (Error?) -> Void) {
//        let supplyRequests = computingSite.suppliesNeeded.map { supplyNeeded -> SupplyRequest in
//            return SupplyRequest(
//                id: UUID().uuidString,
//                countNeeded: supplyNeeded.count,
//                reportID: computingSite.id,
//                reportType: "site_captain",
//                resolved: false,
//                supplyType: supplyNeeded.supply
//            )
//        }
//        
//        let batch = db.batch()
//        
//        for supplyRequest in supplyRequests {
//            let supplyRequestRef = db.collection(supplyRequestCollection).document(supplyRequest.id)
//            batch.setData(try! Firestore.Encoder().encode(supplyRequest), forDocument: supplyRequestRef)
//        }
//        
//        batch.commit { error in
//            if let error = error {
//                print("Error creating supply requests: \(error.localizedDescription)")
//                completion(error)
//            } else {
//                print("Supply requests created successfully!")
//                completion(nil)
//            }
//        }
//    }
}

