//
//  Route.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/8/24.
//

import Foundation
import SwiftUI


enum Destination: Hashable {
    case inventorySitesList
    case detailedInventorySite(InventorySite)
    case inventorySubmission(InventorySite)
    case inventoryChange(InventorySite)
    case test
}

// https://medium.com/@Lakshmnaidu/navigation-in-swiftui-923e3c2c58c6
final public class AppRouter: ObservableObject {
    
    // enum is used to specify the detail view type
    @Published var navPath = NavigationPath() // path which manages the navigations on NavigationStack
    
    // pushing the destination
    func push(to destination: any Hashable) {
        navPath.append(destination)
    }
    
    // pop or removing the destination
    func pop(_ count: Int?) {
        navPath.removeLast(count ?? 1)
    }
    
    // removing all presenters and showing root
    func popToRooot() {
        navPath.removeLast(navPath.count)
    }
}
