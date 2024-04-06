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
    let issues: [Issue]
    let labelsForReplacement: [String]
    let suppliesNeeded: [SupplyNeeded]
    let timestamp: Date
    let updatedInventory: Bool
    let user: String
    
    init(
        id: String,
        issues: [Issue]?,
        labelsForReplacement:[String]?,
        suppliesNeeded:[SupplyNeeded]?,
        timestampValue : Date?,
        updatedInventory: Bool?,
        user : String
        
    ) {
        
        self.id = id
        self.issues = issues ?? []
        self.labelsForReplacement = labelsForReplacement ?? []
        self.suppliesNeeded = suppliesNeeded ?? []
        self.timestamp = timestampValue ?? Date()
        self.updatedInventory = updatedInventory ?? false
        self.user = user
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
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
        self.issues = try container.decode([Issue].self, forKey: .issues)
        self.labelsForReplacement = try container.decode([String].self, forKey: .labelsForReplacement)
        self.suppliesNeeded = try container.decode([SupplyNeeded].self, forKey: .suppliesNeeded)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.updatedInventory = try container.decode(Bool.self, forKey: .updatedInventory)
        self.user = try container.decode(String.self, forKey: .user)
    }
    
    
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
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
    let ticket: Int
}

struct SupplyNeeded: Codable {
    let count: Int
    let supply: String
}


class SiteCaptainManager {
    static let shared = SiteCaptainManager()
    private init() { }
    
    private let db = Firestore.firestore()
    private let computingSitesCollection = "computing_sites"
    
    private var cancellables = Set<AnyCancellable>()
    
    func addComputingSite(_ computingSite: ComputingSite) -> AnyPublisher<Void, Error> {
        let document = db.collection(computingSitesCollection).document(computingSite.id)
        return Future<Void, Error> { promise in
            do {
                try document.setData(from: computingSite) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateComputingSite(_ computingSite: ComputingSite) -> AnyPublisher<Void, Error> {
        let document = db.collection(computingSitesCollection).document(computingSite.id)
        return Future<Void, Error> { promise in
            do {
                try document.setData(from: computingSite, merge: true) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func removeComputingSite(withId siteId: String) -> AnyPublisher<Void, Error> {
        let document = db.collection(computingSitesCollection).document(siteId)
        return Future<Void, Error> { promise in
            document.delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getComputingSite(withId siteId: String) -> AnyPublisher<ComputingSite?, Error> {
        let document = db.collection(computingSitesCollection).document(siteId)
        return Future<ComputingSite?, Error> { promise in
            document.getDocument { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else if let snapshot = snapshot, snapshot.exists {
                    do {
                        let computingSite = try snapshot.data(as: ComputingSite.self)
                        promise(.success(computingSite))
                    } catch {
                        promise(.failure(error))
                    }
                } else {
                    promise(.success(nil))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
