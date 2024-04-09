//
//  Route.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/8/24.
//

import Foundation

enum Route: Hashable {
    case inventorySitesList
    case detailedInventorySite(InventorySite)
    case inventorySubmission(InventorySite)
    case inventoryChange(InventorySite)
}
