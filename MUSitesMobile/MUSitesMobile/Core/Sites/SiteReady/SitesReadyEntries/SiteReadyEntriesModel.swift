//  SiteReadyEntriesModel.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 4/19/24.
//

import Foundation
import FirebaseFirestoreSwift

@MainActor
class SitesReadyEntriesViewModel: ObservableObject {
    // site captain list
    @Published var siteReadys: [SiteReady] = []
    
    // for labels
    var sites: [Site] = []
    var users: [DBUser] = []
    var issueTypes: [IssueType] = []
    var issues: [Issue] = []
    var supplyTypes: [SupplyType] = []
    var supplyRequests: [SupplyRequest] = []
    
    // query info
    @Published var selectedSort = SortOption.descending
    @Published var startDate = Calendar.current.date(byAdding: .day, value: -180, to: Date())!
    @Published var endDate = Date()
    @Published var selectedSite: Site = Site(id: "", name: "any site", buildingId: "", nearestInventoryId: "", chairCounts: [ChairCount(count: 0, type: "")], siteTypeId: "", hasClock: false, hasInventory: false, hasWhiteboard: false, hasPosterBoard: false, namePatternMac: "", namePatternPc: "", namePatternPrinter: "", calendarName: "")
    
    func swapEntriesOrder() {
        siteReadys.reverse()
    }
    
    func getSites(completion: @escaping () -> Void) {
        Task {
            do {
                self.sites = try await SitesManager.shared.getAllSites(descending: false)
            } catch {
                print("Error fetching computing sites: \(error)")
            }
            completion()
        }
    }
    
    func getUsers(completion: @escaping () -> Void) {
        Task {
            do {
                self.users = try await UserManager.shared.getUsersList()
                self.users = self.users.sorted{ $0.fullName ?? "" <  $1.fullName ?? "" }
            } catch  {
                print("Error getting users: \(error)")
            }
            completion()
        }
    }
    
    func getIssueTypes() {
        Task {
            do {
                self.issueTypes = try await IssueTypeManager.shared.getAllIssueTypes(descending: false)
            } catch  {
                print("Error getting issue types: \(error)")
            }
        }
    }
    
    func getSupplyTypes() {
        Task {
            self.supplyTypes = try await SupplyTypeManager.shared.getAllSupplyTypes(descending: false)
        }
    }
    
    func getSiteReadys(siteId: String?, completion: @escaping () -> Void) {
        Task {
            if let siteId {
                do {
                    self.siteReadys = try await SiteReadyManager.shared.getAllSiteReadys(dateDescending: selectedSort.sortDescending, siteId: siteId, startDate: startDate, endDate: endDate)
                } catch {
                    print("Error fetching siteReadys: \(error)")
                }
                completion()
            } else {
                do {
                    self.siteReadys = try await SiteReadyManager.shared.getAllSiteReadys(dateDescending: selectedSort.sortDescending, siteId: nil, startDate: startDate, endDate: endDate)                } catch {
                    print("Error fetching siteReadys: \(error)")
                }
                completion()
            }
        }
    }
    
    func getIssues(completion: @escaping () -> Void) {
        Task {
            do {
                self.issues = []
                for entry in self.siteReadys {
                    guard let issueIds = entry.issues else {
                        continue }
                    for issueId in issueIds {
                        let issue = try await IssueManager.shared.getIssue(issueId: issueId)
                        self.issues.append(issue)
                    }
                }
            } catch {
                print("Error fetching issues: \(error)")
            }
            print("Got \(self.issues.count) issues.")
            completion()
        }
    }
    
    func getSupplyRequests(completion: @escaping () -> Void) {
        Task {
            do {
                self.supplyRequests = []
                for entry in self.siteReadys {
                    guard let requestIds = entry.supplyRequests else { continue }
                    for requestId in requestIds {
                        let request = try await SupplyRequestManager.shared.getSupplyRequest(supplyRequestId: requestId)
                        self.supplyRequests.append(request)
                    }
                }
            } catch {
                print("Error fetching supplyRequests: \(error)")
            }
            print("Got \(self.supplyRequests.count) supplyRequests.")
            completion()
        }
    }
}
