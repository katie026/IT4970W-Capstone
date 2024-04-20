//
//  SiteReadyEntriesModel.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 4/19/24.
//

import Foundation

struct SiteReadyEntry: Codable {
    var comments: String
    var computingSite: String
    var id: String
    var issues: [String]
    var macCount: Int
    var missingChairs: Int
    var pcCount: Int
    var posters: [Poster]
    var scannerComputers: [String]
    var scannerCount: Int
    var timestamp: Date
    var user: String
}

struct Poster: Codable {
    var posterType: String
    var status: String
}
