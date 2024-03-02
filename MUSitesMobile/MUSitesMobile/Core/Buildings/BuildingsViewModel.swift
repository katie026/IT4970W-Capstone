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
        // set sort option
        self.selectedSort = option
        // get buildings again
        self.getBuildings()
    }
    
    func filterSelected(option: FilterOption) async throws {
        // set filter option
        self.selectedFilter = option
        // get buildings again
        self.getBuildings()
        
    }
    
    func getBuildings() {
        Task {
            self.buildings = try await BuildingsManager.shared.getAllBuildings(descending: selectedSort?.sortDescending, group: selectedFilter?.filterKey)
        }
    }
    
    func addUserBuilding(buildingId: String) {
        Task {
            // get current users authData
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            // create userBuilding
            try? await UserManager.shared.addUserBuilding(userId: authDataResult.uid, buildingId: buildingId)
        }
    }
}
