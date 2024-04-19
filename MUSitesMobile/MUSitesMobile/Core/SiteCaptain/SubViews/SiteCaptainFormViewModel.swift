//
//  SiteCaptainFormViewModel.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 4/3/24.
//
import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

class SiteCaptainViewModel: ObservableObject {
    
  @Published var siteCleanedToggle = false
  @Published var selectedThingsToClean = [Bool](repeating: false, count: 7)
  @Published var selectedThingsToDo = [Bool](repeating: false, count: 4)
  @Published var needsRepair = false
  @Published var issueDescription = ""
  @Published var ticketNumber = ""
  @Published var needsLabelReplacement = false
  @Published var labelsToReplace = ""
  @Published var hasInventoryLocation = false
  @Published var inventoryChecked = false
  @Published var showSubmissionConfirmation = false
  @Published var submissionError: Error?
    

    private var cancellables = Set<AnyCancellable>()
    private let siteCaptainManager = SiteCaptainManager()

    func submitSiteCaptainEntry(for siteId: String, userId: String, siteName: String) {
        let issues = needsRepair ? [Issue(issue: issueDescription, ticket: Int(ticketNumber) ?? 1111111)] : []
        let labelsForReplacement = needsLabelReplacement ? labelsToReplace.components(separatedBy: ",") : []
        let suppliesNeeded: [SupplyNeeded] = [] // Populate this based on your requirements

        let firestore = Firestore.firestore()
        let newDocumentReference = firestore.collection("site_captain_entries").document()
        let computingSite = ComputingSite(
            id: newDocumentReference.documentID,
            siteId: siteId,
            siteName: siteName,
            issues: issues,
            labelsForReplacement: labelsForReplacement,
            suppliesNeeded: suppliesNeeded,
            timestampValue: Date(),
            updatedInventory: inventoryChecked,
            user: userId
        )

        siteCaptainManager.submitSiteCaptainEntry(computingSite) { error in
            if let error = error {
                self.submissionError = error
            } else {
                self.showSubmissionConfirmation = true
            }
        }
    }
    
  func resetForm()
    {
        siteCleanedToggle = false
        selectedThingsToClean = [Bool](repeating: false, count: 7)
        selectedThingsToDo = [Bool](repeating: false, count: 4)
        needsRepair = false
        issueDescription = ""
        ticketNumber = ""
        needsLabelReplacement = false
        labelsToReplace = ""
        hasInventoryLocation = false
        inventoryChecked = false
        showSubmissionConfirmation = false
        submissionError = nil
    }
}
