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
    @Published var submitButtonActive: Bool = false
    @Published var selectedThingsToClean: [Bool] = Array(repeating: false, count: 7)
    @Published var selectedThingsToDo: [Bool] = Array(repeating: false, count: 4)
    @Published var needsRepair: Bool = false
    @Published var issues: [Issue] = []
    @Published var issueDescription: String = ""
    @Published var ticketNumber: String = ""
    @Published var needsLabelReplacement: Bool = false
    @Published var labelsToReplace: String = ""
    @Published var hasInventoryLocation: Bool = false
    @Published var inventoryChecked: Bool = false
    @Published var needsSupplies: Bool = false
    @Published var suppliesNeeded: [SupplyNeeded] = []
    @Published var showSubmissionConfirmation: Bool = false
    @Published var submissionError: Error?
    var user: AuthDataResultModel? = nil
    
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
        submitButtonActive = false
        selectedThingsToClean = Array(repeating: false, count: 7)
        selectedThingsToDo = Array(repeating: false, count: 4)
        needsRepair = false
        issues = []
        issueDescription = ""
        ticketNumber = ""
        needsLabelReplacement = false
        labelsToReplace = ""
        hasInventoryLocation = false
        inventoryChecked = false
        needsSupplies = false
        suppliesNeeded = []
        showSubmissionConfirmation = false
        submissionError = nil
    }
    
    // Method to submit the site captain entry
    func submitSiteCaptainEntry(for siteId: String, siteName: String, userId: String) {
        let issues = needsRepair ? [SiteCaptainIssue(issue: issueDescription, ticket: ticketNumber)] : []
        let labelsForReplacement = needsLabelReplacement ? labelsToReplace.components(separatedBy: ",") : []
        
        let siteCaptain = SiteCaptain (
            id: UUID().uuidString,
            siteId: siteId,
            siteName: siteName,
            issues: issues,
            labelsForReplacement: labelsForReplacement,
            suppliesNeeded: suppliesNeeded,
            timestampValue: Date(),
            updatedInventory: inventoryChecked,
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
