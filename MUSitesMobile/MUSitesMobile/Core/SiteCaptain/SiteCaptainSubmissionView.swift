//
//  SiteCaptainSubmissionView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/26/24.
//

import SwiftUI
import FirebaseAuth

struct SiteCaptainSubmissionView: View {
    var siteName: String
    @StateObject private var viewModel = SiteCaptainViewModel()
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Site Captain Form")
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
                
                Button(action: submitSiteCaptain) {
                    Text("Submit Site Captain Entry")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Site Captain Form for \(siteName)")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $viewModel.showSubmissionConfirmation) {
                Alert(title: Text("Submission Successful"),
                      message: Text("Your site captain entry has been submitted."),
                      dismissButton: .default(Text("OK"), action: {
                    viewModel.resetForm()
                }))
            }
            .onReceive(viewModel.$submissionError) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    errorMessage = nil
                }
            }
        }
    }
    
    func submitSiteCaptain() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "Unable to get current user information."
            return
        }
        
        viewModel.submitSiteCaptainEntry(for: "site-123", userId: currentUser.uid, siteName: siteName)
    }
}
