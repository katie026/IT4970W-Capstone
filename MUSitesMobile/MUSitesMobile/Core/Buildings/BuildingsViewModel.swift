//
//  BuildingsViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/19/24.
//

import Foundation

@MainActor
final class BuildingsViewModel: ObservableObject {
    
    @Published private(set) var buildings: [Building] = []
    @Published private(set) var buildingTest: Building? = nil
    @Published var selectedFilter: FilterOption? = nil
    @Published var selectedCategory: CategoryOption? = nil
    
    enum FilterOption: String, CaseIterable {
        // CaseIterable so we can loop through them
        case noFilter
        case name
        case siteGroup
        case isLibrary
        case isResHall
    }
    
    enum CategoryOption: String, CaseIterable { // may want to relocate this eventually
        // CaseIterable so we can loop through them
        case noCategory
        case siteGroup
        case isLibrary
        case isResHall
    }
    
    func getAllBuildings() async throws {
        self.buildings = try await BuildingsManager.shared.getAllBuildings()
    }
    
    func getBuilding(id: String) async throws {
        // Physics ID: vefZkRvjBxS1H1vSzR60
        // use authData to get user data from Firestore as Building struct
        self.buildingTest = try await BuildingsManager.shared.getBuilding(buildingId: id)
    }
    
    func filterSelected(option: FilterOption) async throws {
        switch option {
        case .noFilter:
            self.buildings = try await BuildingsManager.shared.getAllBuildings()
            break
        case .name:
            self.buildings = try await BuildingsManager.shared.getAllBuildingsSortedByName(descending: false)
            break
        case .siteGroup:
            // query sorted buildings and assign to buildings list
            self.buildings = try await BuildingsManager.shared.getAllBuildingsSortedByGroup(descending: false)
            break
        case .isLibrary:
            break
        case.isResHall:
            break
        }
        
        // update the selected filter
        self.selectedFilter = option
    }
    
    func categorySelected(option: CategoryOption) async throws {
        switch option {
        case .noCategory:
            // get all buildings
            self.buildings = try await BuildingsManager.shared.getAllBuildings()
            break
        case .siteGroup:
            // query sorted buildings and assign to buildings list
            self.buildings = try await BuildingsManager.shared.getAllBuildingsSortedByGroup(site_group: option.rawValue)
            break
        case .isLibrary:
            break
        case.isResHall:
            break
        }
        
        // update the selected filter
        self.selectedCategory = option
    }
}
