//
//  SiteCaptainSubmissionView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/26/24.
//

import SwiftUI

struct SiteCaptainSubmissionView: View {
    var siteName: String
    @StateObject private var viewModel = SiteCaptainViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Body")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                SiteCaptainFormView(
                    siteCleanedToggle: $viewModel.siteCleanedToggle,
                    selectedThingsToClean: $viewModel.selectedThingsToClean,
                    selectedThingsToDo: $viewModel.selectedThingsToDo,
                    needsRepair: $viewModel.needsRepair,
                    issueDescription: $viewModel.issueDescription,
                    ticketNumber: $viewModel.ticketNumber,
                    needsLabelReplacement: $viewModel.needsLabelReplacement,
                    labelsToReplace: $viewModel.labelsToReplace,
                    hasInventoryLocation: $viewModel.hasInventoryLocation,
                    inventoryChecked: $viewModel.inventoryChecked
                )
                
                Button(action: {
                 }) {
                 Text("Submit Site Captain Entry")
                 .font(.headline)
                 .foregroundColor(.white)
                 .padding()
                 .frame(maxWidth: .infinity)
                 .background(Color.blue)
                 .cornerRadius(10)
                 }
                 .padding()
                 }
                 }
                .navigationTitle("Site Captain Form for \(siteName)")
                .navigationBarTitleDisplayMode(.inline)
                .alert(isPresented: $viewModel.showSubmissionConfirmation) {
                    Alert(title: Text("Submission Successful"),
                          message: Text("Your site captain entry has been submitted."),
                          dismissButton: .default(Text("OK")))
                }
            }
        }
