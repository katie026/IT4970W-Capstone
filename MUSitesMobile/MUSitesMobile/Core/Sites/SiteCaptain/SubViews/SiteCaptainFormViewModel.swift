//
//  SiteCaptainFormViewModel.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 4/3/24.
//
import Foundation
import SwiftUI
import Combine

class SiteCaptainViewModel: ObservableObject {
    // current user
    var user: AuthDataResultModel? = nil
    // options
    var computers: [Computer] = []
    var printers: [Printer] = []
    var issueTypesNoTickets = ["FldaGVfpPdQ57H7XsGOO" /*chair*/,
                                 "GxFGSkbDySZmdkCFExt9" /*label*/,
                                 "wYJWtaj33rx4EIh6v9RY" /*poster*/]
    // site captain data
    @Published var selectedThingsToClean: [Bool] = []
    @Published var selectedThingsToDo: [Bool] = []
    @Published var hasIssues: Bool = false
    @Published var issueCount = 0
    @Published var issues: [Issue] = []
    @Published var hasLabelIssues: Bool = false
    @Published var labelIssueCount = 0
    @Published var labelIssues: [Issue] = []
    @Published var inventoryUpdated: Bool = false
    @Published var needsSupplies: Bool = false
    @Published var supplyRequestCount = 0
    @Published var supplyRequests: [SupplyRequest] = []
    // view control
    @Published var resultMessage = ""
    // To Do Lists (hardcoded)
    @Published var thingsToClean = [
        "Wipe down the keyboards, mice, all desks, and monitors for each workstation",
        "Wipe down the printer",
        "Tidy up the cords",
        "Push in the chairs",
        "Ensure every computer has a chair",
        "Fill the printer with paper",
        "Clean whiteboard (if there is one)"
    ]
    @Published var thingsToDo = [
        "Check the projector (if there is one)",
        "Check the dry erase markers",
        "Check the classroom calendars are up to date (if not, contact a CS)",
        "Remove non-DoIT posters from the classroom poster board"
    ]
    
    private var cancellables: Set<AnyCancellable> = []
//    private let siteCaptainManager = SiteCaptainManager()
    
    func getUser() {
        Task {
            // get current user
            self.user = try AuthenticationManager.shared.getAuthenticatedUser()
        }
    }
    
    func getSupplyTypes(completion: @escaping () -> Void) {
        SupplyTypeManager.shared.fetchSupplyTypes()
        print("Queried supply types.")
        completion()
    }
    
    func getIssueTypes(completion: @escaping () -> Void) {
        IssueTypeManager.shared.fetchIssueTypes()
        print("Queried issue types.")
        completion()
    }
    
    func getSiteComputers(siteId: String, completion: @escaping () -> Void) {
        Task {
            do {
                self.computers = try await ComputerManager.shared.getAllComputers(descending: false, siteId: siteId)
            } catch {
                print("Error fetching computers: \(error)")
            }
            print("Got \(self.computers.count) computers.")
            completion()
        }
    }
    
    func getSitePrinters(siteId: String, completion: @escaping () -> Void) {
        Task {
            do {
                self.printers = try await PrinterManager.shared.getAllPrinters(descending: false, siteId: siteId)
            } catch {
                print("Error fetching printers: \(error)")
            }
            print("Got \(self.printers.count) printers.")
            completion()
        }
    }
    
    // Method to submit the site captain entry
    func submitSiteCaptainEntry(site: Site, completion: @escaping () -> Void) {
        Task {
            do {
                // if user is logged in (authorized)
                if let user = user {
                    // create empty SiteCaptain document and get id
                    let siteCaptainId = try await SiteCaptainManager.shared.getNewSiteCaptainId()
                    
                    // create issues
                    // for each issue in issues
                    for index in issues.indices {
                        // create new empty Issue document and get id
                        let newIssueId = try await IssueManager.shared.getNewIssueId()
                        // redefine the issue.id and issue.reportId
                        issues[index].id = newIssueId
                        issues[index].reportId = siteCaptainId
                        
                        // if issueType does not need a Cherwell ticket
                        if issueTypesNoTickets.contains(where: { $0 == issues[index].issueTypeId }) {
                            // set the .ticket to nil
                            issues[index].ticket = nil
                        }
                    }
                    // for each labelIssue in labelIssues
                    for index in labelIssues.indices {
                        // create new empty Issue document and get id
                        let newIssueId = try await IssueManager.shared.getNewIssueId()
                        // redefine the labelIssue.id and labelIssue.reportId
                        labelIssues[index].id = newIssueId
                        labelIssues[index].reportId = siteCaptainId
                        // add to labelIssue.description
                        labelIssues[index].description = labelIssues[index].description != nil ? labelIssues[index].description! + " label" : nil
                    }
                    // combine issues and labelIssues
                    let allIssues = issues + labelIssues
                    // update empty issue documents in Firestore
                    try await IssueManager.shared.updateIssues(allIssues)
                    
                    // create supply requests
                    for index in supplyRequests.indices {
                        // create new empty SupplyRequest document and get id
                        let newSupplyRequestId = try await SupplyRequestManager.shared.getNewSupplyRequestId()
                        // redefine the supplyRequest.id and supplyRequest.reportId
                        supplyRequests[index].id = newSupplyRequestId
                        supplyRequests[index].reportId = siteCaptainId
                    }
                    // update empty supplyRequest documents in Firestore
                    try await SupplyRequestManager.shared.updateSupplyRequests(supplyRequests)
                    
                    // create SiteCaptain object
                    // extract issue IDs and create a new array of strings
                    let issueIds = allIssues.map { $0.id }
                    let supplyRequestIds = supplyRequests.map { $0.id }
                    let siteCaptain = SiteCaptain(
                        id: siteCaptainId,
                        siteId: site.id,
                        issues: issueIds,
                        supplyRequests: supplyRequestIds,
                        timestamp: Date(),
                        updatedInventory: inventoryUpdated,
                        user: user.uid
                    )
                    
                    // update siteCaptain document in Firestore
                    try await SiteCaptainManager.shared.updateSiteCaptain(siteCaptain)
                    
                    // update result message
                    resultMessage = "Successfully reported \(issues.count) issues, \(labelIssues.count) labels, and \(supplyRequests.count) supply requests."
                    
                    // call completion handler upon successful creation
                    completion()
                }
            } catch {
                resultMessage = "An error occured! \(error)"
                print("Error creating new site captain entry: \(error)")
            }
        }
    }
}
