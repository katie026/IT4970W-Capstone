//
//  InventorySubmissionViewManager.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/17/24.
//

import Foundation
import FirebaseFirestore

struct Supply: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    var count: Int?
    var confirm: Bool?
    var fix: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case count
        case confirm
        case fix
    }
}

class InventorySubmissionManager {
    static let shared = InventorySubmissionManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func submitInventory(siteId: String, inventoryTypeId: String, supplies: [Supply], comments: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let submissionData: [String: Any] = [
            "siteId": siteId,
            "inventoryTypeId": inventoryTypeId,
            "supplies": supplies.map { supply in
                [
                    "id": supply.id,
                    "count": supply.count ?? 0,
                    "confirm": supply.confirm ?? false,
                    "fix": supply.fix ?? 0
                ]
            },
            "comments": comments,
            "timestamp": Timestamp(date: Date())
        ]
        
        db.collection("inventorySubmissions").addDocument(data: submissionData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
