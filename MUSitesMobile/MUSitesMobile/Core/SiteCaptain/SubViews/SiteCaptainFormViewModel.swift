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
    @Published var siteCleanedToggle: Bool = false
    @Published var selectedThingsToClean: [Bool] = Array(repeating: false, count: 7)
    @Published var selectedThingsToDo: [Bool] = Array(repeating: false, count: 4)
    @Published var needsRepair: Bool = false
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
    
    private var cancellables: Set<AnyCancellable> = []
    private let siteCaptainManager = SiteCaptainManager()
    
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
        siteCleanedToggle = false
        selectedThingsToClean = Array(repeating: false, count: 7)
        selectedThingsToDo = Array(repeating: false, count: 4)
        needsRepair = false
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
        let issues = needsRepair ? [Issue(issue: issueDescription, ticket: ticketNumber)] : []
        let labelsForReplacement = needsLabelReplacement ? labelsToReplace.components(separatedBy: ",") : []
        
        let computingSite = ComputingSite(
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
        
        siteCaptainManager.submitSiteCaptainEntry(computingSite) { [weak self] error in
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