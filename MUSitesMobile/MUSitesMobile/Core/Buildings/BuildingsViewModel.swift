//
//  BuildingsViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/19/24.
//

import Foundation
import FirebaseFirestore

@MainActor
final class BuildingsViewModel: ObservableObject {
    
    @Published private(set) var buildings: [Building] = []
    @Published private(set) var buildingTest: Building? = nil
    @Published var selectedSort: SortOption? = nil
    @Published var selectedFilter: FilterOption? = nil
    private var lastDocument: DocumentSnapshot? = nil
    
    enum SortOption: String, CaseIterable {
        // CaseIterable so we can loop through them
        case noSort
        case nameAscending
        case nameDescending
        
        var sortDescending: Bool? {
            switch self {
            case .noSort: return nil
            case .nameAscending: return false
            case .nameDescending: return true
            }
        }
    }
    
    enum FilterOption: String, CaseIterable { // may want to relocate this eventually
        // CaseIterable so we can loop through them
        case noFilter
        case G1
        case G2
        case G3
        case R1
        case R2
        
        var filterKey: String? {
            if self == .noFilter {
                return nil
            }
            return self.rawValue
        }
    }
    
//    func getAllBuildings() async throws {
//        self.buildings = try await BuildingsManager.shared.getAllBuildings()
//    }
    
    func getBuilding(id: String) async throws {
        // Physics ID: vefZkRvjBxS1H1vSzR60
        // use authData to get user data from Firestore as Building struct
        self.buildingTest = try await BuildingsManager.shared.getBuilding(buildingId: id)
    }
    
    func sortSelected(option: SortOption) async throws {
//        switch option {
//        case .noSort:
//            self.buildings = try await BuildingsManager.shared.getAllBuildings()
//            break
//        case .nameAscending:
//            self.buildings = try await BuildingsManager.shared.getAllBuildingsSortedByName(descending: false)
//            break
//        case .nameDescending:
//            self.buildings = try await BuildingsManager.shared.getAllBuildingsSortedByName(descending: true)
//            break
//        }
        
        // set sort option
        self.selectedSort = option
        // reset building list for pagination
        self.buildings = []
        self.lastDocument = nil
        // get buildings again
        self.getBuildings()
    }
    
    func filterSelected(option: FilterOption) async throws {
//        switch option {
//        case .noFilter:
//            // get all buildings
//            self.buildings = try await BuildingsManager.shared.getAllBuildings()
//            break
//        case .G1, .G2, .G3, .R1, .R2:
//            // query sorted buildings and assign to buildings list
//            self.buildings = try await BuildingsManager.shared.getAllBuildingsByGroup(descending: false, filter: option.rawValue)
//            break
//        case .isLibrary:
//            // query sorted buildings and assign to buildings list
//            self.buildings = try await BuildingsManager.shared.getAllBuildingsFilteredByIsLibrary()
//            break
//        case.isResHall:
//            // query sorted buildings and assign to buildings list
//            self.buildings = try await BuildingsManager.shared.getAllBuildingsFilteredByIsResHall()
//            break
//        }
        
        // set filter option
        self.selectedFilter = option
        // reset building list for pagination
        self.buildings = []
        self.lastDocument = nil
        // get buildings again
        self.getBuildings()
        
    }
    
    func getBuildings() {
        Task {
            let (newBuildings, lastDocument) = try await BuildingsManager.shared.getAllBuildings(descending: selectedSort?.sortDescending, group: selectedFilter?.filterKey, count: 10, lastDocument: lastDocument)
            
            self.buildings.append(contentsOf: newBuildings)
            // if lastDocument is NOT nil, assign the new lastDocument
            if let lastDocument {
                self.lastDocument = lastDocument
            }
            // if lastDocument returns nil (no more documents), don't replace the local lastDocument with nil
        }
    }
    
//    // get Buildings by ex. "Rating" with pagination
//    func getBuildingsByCoordinates() {
//        Task {
//            let (newBuildings, lastDocument) = try await BuildingsManager.shared.getBuildingsByCoordinates(count: 3, lastDocument: lastDocument)
//            self.buildings.append(contentsOf: newBuildings)
//            self.lastDocument = lastDocument
//        }
//    }
}