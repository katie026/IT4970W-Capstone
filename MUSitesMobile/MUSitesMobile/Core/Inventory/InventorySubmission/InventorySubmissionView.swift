//
//  InventorySubmissionView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/15/24.
//

import SwiftUI

@MainActor
final class InventorySubmissionViewModel: ObservableObject {
    @Published var supplyTypes: [SupplyType] = []
    @Published var supplyCounts: [SupplyCount] = []
    @Published var newSupplyCounts: [SupplyCount] = [] // Change to SupplyCount array
    @Published var inventoryEntryType: InventoryEntryType = InventoryEntryType.Check
    @Published var comments: String = ""

    func getSupplyTypes() {
        Task {
            self.supplyTypes = try await SupplyTypeManager.shared.getAllSupplyTypes(descending: true)
        }
    }

    func getSupplyCounts(inventorySiteId: String) {
        Task {
            self.supplyCounts = try await SupplyCountManager.shared.getAllSupplyCountsBySite(siteId: inventorySiteId)

            // Make a copy of each SupplyCount object and assign to newSupplyCounts
            self.newSupplyCounts = self.supplyCounts.map { $0.copy() }
        }
    }

    func createNewSupplyCount(inventorySiteId: String, supplyTypeId: String, completion: @escaping () -> Void) {
        Task {
            do {
                // create new document and get id from Firestore
                let newId = try await SupplyCountManager.shared.getNewSupplyCountId()

                // create a new SupplyCount struct
                let newSupplyCount = SupplyCount(
                    id: newId, // Generate a unique ID
                    inventorySiteId: inventorySiteId,
                    supplyTypeId: supplyTypeId,
                    countMin: 0,
                    count: 0
                )

                // update document with new SupplyCount
                try await SupplyCountManager.shared.createSupplyCount(supplyCount: newSupplyCount)

                // Call the completion handler upon successful creation
                completion()

                print("created new Supply doc in Firestore")
            } catch {
                print("Error creating new supply count: \(error)")
            }
        }
    }

    func submitSupplyCounts(completion: @escaping () -> Void) {
        print("supplyCounts submitted!")
        Task {
            do {
                try await SupplyCountManager.shared.updateSupplyCounts(newSupplyCounts)
                // Call the completion handler upon successful creation
                completion()

                print("Updated supplies doc in Firestore")
            } catch {
                print("Error creating new supply count: \(error)")
            }
        }
    }
}

struct InventorySubmissionView: View {
    @StateObject private var viewModel = InventorySubmissionViewModel()
    @State private var reloadView = false
    @State private var showNoChangesAlert = false
    @State private var showEntryTypeAlert = false
    @Environment(\.presentationMode) private var presentationMode

    let inventorySite: InventorySite

    var body: some View {
        content
            .onAppear {
                Task {
                    viewModel.getSupplyCounts(inventorySiteId: inventorySite.id)
                    viewModel.getSupplyTypes()
                }
            }
            .navigationTitle(inventorySite.name ?? "No name")
            .id(reloadView)
    }

    private var content: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.top)

            VStack(spacing: 16) {
                Text("Submit Inventory")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Form {
                    suppliesSection
                    commentsSection
                    actionButtonsSection
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
    }

    private var suppliesSection: some View {
        Section(header: Text("Supplies")) {
            LazyVGrid(columns: [
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center)
            ]) {
                Text("Supply").fontWeight(.bold)
                Text("Count").fontWeight(.bold)
                Text("Confirm").fontWeight(.bold)
                Text("Fix").fontWeight(.bold)
            }

            if !viewModel.supplyTypes.isEmpty {
                ForEach(viewModel.supplyTypes, id: \.id) { supplyType in
                    supplyRow(for: supplyType)
                }
            } else {
                ProgressView()
            }
        }
    }

    private func supplyRow(for supplyType: SupplyType) -> some View {
        // Find the supply count for the current supply type
        let supplyCount = viewModel.supplyCounts.first(where: { $0.supplyTypeId == supplyType.id })

        // calculate the count, if nil count = 0
        let count = supplyCount?.count ?? 0

        // create 1x4 grid
        return LazyVGrid(columns: [
            GridItem(.flexible(), alignment: .center),
            GridItem(.flexible(), alignment: .center),
            GridItem(.flexible(), alignment: .center),
            GridItem(.flexible(), alignment: .center)
        ]) {

            // supply name column
            Text(supplyType.name)
                .frame(maxWidth: .infinity, alignment: .leading)

            // supply count column
            Text("\(count)")

            // supply toggle column
            HStack {
                Spacer()
                // if there's a supplyCount for the supplyType
                if let supplyCount = supplyCount {
                    // display the toggle
                    supplyToggle(for: supplyCount)
                } else {
                    // display Add button
                    Button("Add") {
                        // create a new SupplyCount in Firestore
                        viewModel.createNewSupplyCount(inventorySiteId: inventorySite.id, supplyTypeId: supplyType.id) {
                            // Reload view upon successful creation
                            reloadView.toggle()
                        }
                    }
                }
                Spacer()
            }

            // supply fix field column
            if let supplyCount = supplyCount, viewModel.newSupplyCounts.contains(where: { $0.id == supplyCount.id }) {
                supplyFixTextField(for: supplyCount)
            }
        }
        .id(supplyType.id) // Specify the id parameter explicitly
    }


    private func supplyToggle(for supplyCount: SupplyCount) -> some View {
        Toggle(isOn: Binding(
            get: {
                !viewModel.newSupplyCounts.contains { $0.id == supplyCount.id }
            },
            set: { confirmed in
                if confirmed {
                    // If confirmed, remove from newSupplyCounts if exists
                    if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                        viewModel.newSupplyCounts.remove(at: index)
                    }
                } else {
                    // If not confirmed, add to newSupplyCounts if not already added
                    if !viewModel.newSupplyCounts.contains(where: { $0.id == supplyCount.id }) {
                        viewModel.newSupplyCounts.append(supplyCount)
                    }
                }
            }
        )) {

        }
    }

    private func supplyFixTextField(for supplyCount: SupplyCount) -> some View {
        TextField("#", text: Binding(
            get: {
                if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                    return "\(viewModel.newSupplyCounts[index].count ?? 0)"
                } else {
                    return ""
                }
            },
            set: { newValue in
                if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                    // Parse the new value as an integer
                    if let newCount = Int(newValue) {
                        // Update the count of the corresponding SupplyCount object
                        viewModel.newSupplyCounts[index].count = newCount
                    }
                }
            }
        ))
        .multilineTextAlignment(.center)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .frame(width: 50)
        .keyboardType(.numberPad)
        .textContentType(.oneTimeCode)
    }

    private var commentsSection: some View {
        Section(header: Text("Comments")) {
            TextEditor(text: $viewModel.comments)
                .frame(height: 100)

            // Display the contents of the newSupplyCounts array
            ForEach(viewModel.newSupplyCounts, id: \.id) { supply in
                HStack {
                    Text("ID: \(supply.id)")
                    Text("Count: \(supply.count ?? 0)")
                }
                .foregroundColor(.white) // Optionally change text color
            }
        }
    }

    private var actionButtonsSection: some View {
        Section {
            HStack {
                Spacer()
                confirmExitButton
                Spacer()
                confirmContinueButton
                Spacer()
            }
        }
    }

    private var confirmExitButton: some View {
        Button(action: {
            // Check if any counts have been changed
            let countsChanged = viewModel.newSupplyCounts.contains { newSupplyCount in
                // find the original count for the supply using the SupplyCount.id
                guard let originalCount = viewModel.supplyCounts.first(where: { $0.id == newSupplyCount.id })?.count else {
                    // if original count not found, counts have changed
                    return true
                }
                // counts have changed if the new count is different from the original count
                return newSupplyCount.count != originalCount
            }

            if countsChanged {
                // If counts have changed, submit the counts
                viewModel.submitSupplyCounts() {
                    // Reload view upon successful creation
                    reloadView.toggle()
                }
            } else {
                // If counts haven't changed, show an alert
                showNoChangesAlert = true
            }

//            // check if all toggles are true
//            let allConfirmed = viewModel.supplyCounts.allSatisfy { supplyCount in
//                viewModel.newSupplyCounts.contains { $0.id == supplyCount.id }
//            }
//
//            if allConfirmed {
//                // if all toggles are true, carry out the action
//                viewModel.submitSupplyCounts() {
//                    // reload view upon successful creation
//                    reloadView.toggle()
//                }
//            } else {
//                // if not, show an alert with options to select
//                showEntryTypeAlert = true
//            }
        }) {
            Text("Confirm & Exit")
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
        .alert(isPresented: $showNoChangesAlert) {
            Alert(title: Text("No Changes"), message: Text("There are no changes to submit."), dismissButton: .default(Text("OK")))
        }
    }

    private var confirmContinueButton: some View {
        Button(action: {
            // Handle "Confirm & Continue" action
        }) {
            Text("Confirm & Continue")
                .foregroundColor(.white)
                .padding()
                .background(Color.yellow)
                .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationView {
        InventorySubmissionView(inventorySite: InventorySite(id: "TzLMIsUbadvLh9PEgqaV", name: "BCC 122", buildingId: "yXT87CrCZCoJVRvZn5DC", inventoryTypeIds: ["TzLMIsUbadvLh9PEgqaV"]))
    }
}

// MARK: Custom Alert

struct EntryTypeAlertView: View {
    @Binding var selectedOption: InventoryEntryType?

    var body: some View {
        VStack {
            Text("You did not confirm all counts, would you like to report this?")
                .font(.headline)
                .padding()

            HStack {
                RadioButton(text: "Yes, there is a discrepancy.", isSelected: selectedOption == .Fix) {
                    selectedOption = .Fix
                }
                .padding()

                RadioButton(text: "Yes, there was a delivery.", isSelected: selectedOption == .Delivery) {
                    selectedOption = .Delivery
                }
                .padding()
            }

            Button("OK") {
                // Dismiss the alert
            }
            .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}
