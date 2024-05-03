//
//  ReportTypeManager.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 5/2/24.
//

import Foundation

enum ReportType {
    case siteCaptain
    case siteReady
    case hourlyCleaning
    case other
    
    var label: String {
        switch self {
        case .siteCaptain: return "Site Captain"
        case .siteReady: return "Site Ready"
        case .hourlyCleaning: return "Hourly Cleaning"
        case .other: return "Unknown"
        }
    }
    
    var code: String {
        switch self {
        case .siteCaptain: return "site_captain"
        case .siteReady: return "site_ready"
        case .hourlyCleaning: return "hourly_cleaning"
        case .other: return ""
        }
    }
}
