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
    let countNeeded: Int?
    let reportID: String?
    let reportType: String?
    let resolved: Bool?
    let supplyType: String?
    
    init(
        id: String,
        countNeeded: Int? = nil,
        reportID: String? = nil,
        reportType: String? = nil,
        resolved: Bool? = nil,
        supplyType: String? = nil)
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
        self.countNeeded = try container.decodeIfPresent(Int.self, forKey: .countNeeded)
        self.reportID = try container.decodeIfPresent(String.self, forKey: .reportID)
        self.reportType = try container.decodeIfPresent(String.self, forKey: .reportType)
        self.resolved = try container.decodeIfPresent(Bool.self, forKey: .resolved)
        self.supplyType = try container.decodeIfPresent(String.self, forKey: .supplyType)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.countNeeded, forKey: .countNeeded)
        try container.encodeIfPresent(self.reportID, forKey: .reportID)
        try container.encodeIfPresent(self.reportType, forKey: .reportType)
        try container.encodeIfPresent(self.resolved, forKey: .resolved)
        try container.encodeIfPresent(self.supplyType, forKey: .supplyType)
    }
}
