//
//  SitesViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/29/24.
//

import Foundation

@MainActor
final class SitesViewModel: ObservableObject {
    @Published private(set) var sites: [Site] = []
    @Published var selectedSort: SortOption? = nil
    @Published var selectedFilter: FilterOption? = nil
    var buildings: [Building] = [] // Add buildings property
    var siteTypes: [SiteType] = []
    var siteGroups: [SiteGroup] = []
    
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
    
    func getBuildings(completion: @escaping () -> Void) {
        Task {
            do {
                self.buildings = try await BuildingsManager.shared.getAllBuildings(descending: nil, group: nil)
                completion()
            } catch {
                print("Error getting buildings: \(error)")
            }
        }
    }
    
    func getSiteTypes(completion: @escaping () -> Void) {
        Task {
            do {
                self.siteTypes = try await SiteTypeManager.shared.getAllSiteTypes(descending: nil)
                completion()
            } catch {
                print("Error getting site types: \(error)")
            }
        }
    }
    
    func getSiteGroups(completion: @escaping () -> Void) {
        Task {
            do {
                self.siteGroups = try await SiteGroupManager.shared.getAllSiteGroups(descending: nil)
                completion()
            } catch {
                print("Error getting site groups: \(error)")
            }
        }
    }
    
    func sortSelected(option: SortOption) async throws {
        // set sort option
        self.selectedSort = option
        // get sites again
        self.getSites{}
    }
    
    func getSites(completion: @escaping () -> Void) {
        Task {
            self.sites = try await SitesManager.shared.getAllSites(descending: selectedSort?.sortDescending)
            completion()
        }
    }
}
