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
    @Published var selectedGroup: SiteGroup? = nil
    var buildings: [Building] = [] // Add buildings property
    var siteTypes: [SiteType] = []
    var siteGroups: [SiteGroup] = []
    
    func getBuildings(completion: @escaping () -> Void) {
        Task {
            do {
                self.buildings = try await BuildingsManager.shared.getAllBuildings(descending: false, group: nil)
                completion()
            } catch {
                print("Error getting buildings: \(error)")
            }
        }
    }

    func getSiteTypes(completion: @escaping () -> Void) {
        Task {
            do {
                self.siteTypes = try await SiteTypeManager.shared.getAllSiteTypes(descending: false)
                completion()
            } catch {
                print("Error getting site types: \(error)")
            }
        }
    }
    
    func getSiteGroups(completion: @escaping () -> Void) {
        Task {
            do {
                self.siteGroups = try await SiteGroupManager.shared.getAllSiteGroups(descending: false)
                completion()
            } catch {
                print("Error getting site groups: \(error)")
            }
        }
    }
    
    func getSites(completion: @escaping () -> Void) {
        Task {
            self.sites = try await SitesManager.shared.getAllSites(descending: false)
            completion()
        }
    }
    
    func swapSitesOrder() {
        sites.reverse()
    }
}
