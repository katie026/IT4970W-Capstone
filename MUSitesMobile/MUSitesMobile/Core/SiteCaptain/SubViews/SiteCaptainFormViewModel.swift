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
    // site captain data
    @Published var selectedThingsToClean: [Bool] = []
    @Published var selectedThingsToDo: [Bool] = []
    @Published var hasIssues: Bool = false
    @Published var needsSupplies: Bool = false
    @Published var issueCount = 0
    @Published var issues: [Issue] = []
    @Published var hasLabelIssues: Bool = false
    @Published var labelIssueCount = 0
    @Published var labelIssues: [Issue] = []
    @Published var inventorySubmitted: Bool = false
    @Published var suppliesNeeded: [SupplyNeeded] = []
    @Published var showSubmissionConfirmation: Bool = false
    @Published var submissionError: Error?
    @Published var hasInventoryLocation: Bool = false // delete eventually
    @Published var issueDescription: String = "" // delete eventually
    @Published var ticketNumber: String = "" // delete eventually
    @Published var labelsToReplace: String = ""  // delete eventually
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
    private let siteCaptainManager = SiteCaptainManager()
    
    func getUser() {
        Task {
            // get current user
            self.user = try AuthenticationManager.shared.getAuthenticatedUser()
        }
    }
    
    func getSupplyTypes() {
        SupplyTypeManager.shared.fetchSupplyTypes()
        print("Queried supply types.")
    }
    
    func getIssueTypes() {
        IssueTypeManager.shared.fetchIssueTypes()
        print("Queried issue types.")
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
    
    // Method to add a supply with its count to the suppliesNeeded array
    func addSupply(supply: SupplyType, count: Int) {
        let newSupplyNeeded = SupplyNeeded(count: count, supply: supply.id)
        suppliesNeeded.append(newSupplyNeeded)
    }
    
    // Method to remove a supply from the suppliesNeeded array
    func removeSupply(at index: Int) {
        suppliesNeeded.remove(at: index)
    }
    
    // Method to reset the form and clear all fields
    func resetForm() {
        selectedThingsToClean = Array(repeating: false, count: 7)
        selectedThingsToDo = Array(repeating: false, count: 4)
        hasIssues = false
        issues = []
        issueDescription = ""
        ticketNumber = ""
        hasLabelIssues = false
        labelsToReplace = ""
        hasInventoryLocation = false
        inventorySubmitted = false
        needsSupplies = false
        suppliesNeeded = []
        showSubmissionConfirmation = false
        submissionError = nil
    }
    
    // Method to submit the site captain entry
    func submitSiteCaptainEntry(site: Site, userId: String) {
        let issues = hasIssues ? [SiteCaptainIssue(issue: issueDescription, ticket: ticketNumber)] : []
        let labelsForReplacement = hasLabelIssues ? labelsToReplace.components(separatedBy: ",") : []
        
        //TODO: make ticket # nil if chair, label, or poster issue
        
        let siteCaptain = SiteCaptain (
            id: UUID().uuidString,
            siteId: site.id,
            issues: issues,
            labelsForReplacement: labelsForReplacement,
            suppliesNeeded: suppliesNeeded,
            timestampValue: Date(),
            updatedInventory: inventorySubmitted,
            user: userId
        )
        
        siteCaptainManager.submitSiteCaptainEntry(siteCaptain) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.submissionError = error
                } else {
                    self?.showSubmissionConfirmation = true
                }
            }
        }
    }
}
