//
//  SiteCaptainSubmissionView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/26/24.
//

import SwiftUI
import FirebaseAuth

struct SiteCaptainSubmissionView: View {
    var siteId: String
    var siteName: String
    @StateObject private var viewModel = SiteCaptainViewModel()
    @State private var errorMessage: String?
    @State private var selectedSupplyType: SupplyType?
    @State private var needsSupplies: Bool = false
    @State private var suppliesNeededCount: Int = 1 // Initialize with default value

    var body: some View {
        ScrollView {
            VStack {
                // Subtitle
                HStack {
                    Text("\(siteName)")
                        .font(.title2)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)

                SiteCaptainFormView(
                    submitButtonActive: $viewModel.submitButtonActive,
                    selectedThingsToClean: $viewModel.selectedThingsToClean,
                    selectedThingsToDo: $viewModel.selectedThingsToDo,
                    needsRepair: $viewModel.needsRepair,
                    issueDescription: $viewModel.issueDescription,
                    ticketNumber: $viewModel.ticketNumber,
                    needsLabelReplacement: $viewModel.needsLabelReplacement,
                    labelsToReplace: $viewModel.labelsToReplace,
                    hasInventoryLocation: $viewModel.hasInventoryLocation,
                    inventoryChecked: $viewModel.inventoryChecked,
                    suppliesNeeded: $viewModel.suppliesNeeded, // Pass suppliesNeeded binding
                    suppliesNeededCount: $suppliesNeededCount, // Pass suppliesNeededCount binding
                    selectedSupplyType: $selectedSupplyType,
                    needsSupplies: $needsSupplies
                )
                
                if viewModel.submitButtonActive {
                    Button(action: submitSiteCaptain) {
                        Text("SUBMIT")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                } else {
                    Text("SUBMIT")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray4))
                        .cornerRadius(10)
                        .padding()
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Site Captain")
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
        .onAppear {
            SupplyTypeManager.shared.fetchSupplyTypes()
        }
    }

    func submitSiteCaptain() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "Unable to get current user information."
            return
        }

        if let selectedSupplyType = selectedSupplyType {
            viewModel.addSupply(supply: selectedSupplyType, count: suppliesNeededCount)
        }

        viewModel.submitSiteCaptainEntry(
            for: siteId,
            siteName: siteName,
            userId: currentUser.uid
        )
    }
}

#Preview {
    NavigationView {
        SiteCaptainSubmissionView(
            siteId: "BezlCe1ospf57zMdop2z",
            siteName: "Bluford"
        )
    }
}
