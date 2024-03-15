//
//  SitesViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/29/24.
//

import Foundation

final class SitesViewModel: ObservableObject {
    
    @Published private(set) var sites: [Site] = []
    @Published private(set) var siteTest: Site? = nil
    @Published var selectedSort: SortOption? = nil
    @Published var selectedFilter: FilterOption? = nil
    @Published private(set) var buildings: [Building] = [] // Add buildings property
    
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
        case hasInventory
        
        var filterKey: String? {
            if self == .noFilter {
                return nil
            }
            return self.rawValue
        }
    }
    
    func getAllBuildings() async throws {
        self.buildings = try await BuildingsManager.shared.getAllBuildings(descending: nil, group: nil)
    }
    
    func getSite(id: String) async throws {
        self.siteTest = try await SitesManager.shared.getSite(siteId: id)
    }
    
    func sortSelected(option: SortOption) async throws {
        // set sort option
        self.selectedSort = option
        // get sites again
        self.getSites()
    }
    
    func getSites() {
        Task {
            self.sites = try await SitesManager.shared.getAllSites(descending: selectedSort?.sortDescending)
        }
    }
}
