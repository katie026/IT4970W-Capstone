//
//  SupplyRequestManager.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 4/20/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SupplyRequest: Codable {
    let id: String
    let countNeeded: Int
    let reportID: String
    let reportType: String
    let resolved: Bool
    let supplyType: String
    
    init(
        id: String,
        countNeeded: Int,
        reportID: String,
        reportType: String,
        resolved: Bool,
        supplyType: String)
    {
        self.id = id
        self.countNeeded = countNeeded
        self.reportID = reportID
        self.reportType = reportType
        self.resolved = resolved
        self.supplyType = supplyType
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case countNeeded = "count_needed"
        case reportID = "report_id"
        case reportType = "report_type"
        case resolved = "resolved"
        case supplyType = "supply_type"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.countNeeded = try container.decode(Int.self, forKey: .countNeeded)
        self.reportID = try container.decode(String.self, forKey: .reportID)
        self.reportType = try container.decode(String.self, forKey: .reportType)
        self.resolved = try container.decode(Bool.self, forKey: .resolved)
        self.supplyType = try container.decode(String.self, forKey: .supplyType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.countNeeded, forKey: .countNeeded)
        try container.encode(self.reportID, forKey: .reportID)
        try container.encode(self.reportType, forKey: .reportType)
        try container.encode(self.resolved, forKey: .resolved)
        try container.encode(self.supplyType, forKey: .supplyType)
    }
    
    
}
