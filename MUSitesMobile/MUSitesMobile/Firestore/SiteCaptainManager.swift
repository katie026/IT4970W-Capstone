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

struct ComputingSite: Codable {
    let id: String
    let siteId:String
    let siteName: String
    let issues: [Issue]
    let labelsForReplacement: [String]
    let suppliesNeeded: [SupplyNeeded]
    let timestamp: Date
    let updatedInventory: Bool
    let user: String
    
    init(
        id: String,
        siteId:String,
        siteName:String,
        issues: [Issue]?,
        labelsForReplacement:[String]?,
        suppliesNeeded:[SupplyNeeded]?,
        timestampValue : Date?,
        updatedInventory: Bool?,
        user : String
        
    ) {
        
        self.id = id
        self.siteId = siteId
        self.siteName = siteName
        self.issues = issues ?? []
        self.labelsForReplacement = labelsForReplacement ?? []
        self.suppliesNeeded = suppliesNeeded ?? []
        self.timestamp = timestampValue ?? Date()
        self.updatedInventory = updatedInventory ?? false
        self.user = user
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case siteId = "siteId"
        case siteName = "siteName"
        case issues = "issues"
        case labelsForReplacement = "labels_for_replacement"
        case suppliesNeeded = "supplies_needed"
        case timestamp = "timestamp"
        case updatedInventory = "updated_inventory"
        case user = "user"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.siteId = try container.decode(String.self, forKey: .siteId)
        self.siteName = try container.decode(String.self, forKey: .siteName)
        self.issues = try container.decode([Issue].self, forKey: .issues)
        self.labelsForReplacement = try container.decode([String].self, forKey: .labelsForReplacement)
        self.suppliesNeeded = try container.decode([SupplyNeeded].self, forKey: .suppliesNeeded)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.updatedInventory = try container.decode(Bool.self, forKey: .updatedInventory)
        self.user = try container.decode(String.self, forKey: .user)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.siteId, forKey: .siteId)
        try container.encode(self.siteName, forKey: .siteName)
        try container.encode(self.issues, forKey: .issues)
        try container.encode(self.labelsForReplacement, forKey: .labelsForReplacement)
        try container.encode(self.suppliesNeeded, forKey: .suppliesNeeded)
        try container.encode(self.timestamp, forKey: .timestamp)
        try container.encode(self.updatedInventory, forKey: .updatedInventory)
        try container.encode(self.user, forKey: .user)
    }

}

struct Issue: Codable {
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
    
    
    func submitSiteCaptainEntry(_ computingSite: ComputingSite, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection(siteCaptainEntry).document(computingSite.id).setData(from: computingSite) { error in
                if let error = error {
                    print("Error submitting site captain entry: \(error.localizedDescription)") // Add this line
                    completion(error)
                } else {
                    print("Site captain entry submitted successfully!") // Add this line
                    completion(nil)
                }
            }
        } catch {
            print("Error encoding site captain entry: \(error.localizedDescription)") // Add this line
            completion(error)
        }
    }
}
