//
//  InventorySubmissionView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/15/24.
//

import SwiftUI

struct InventorySubmissionView: View {
    @StateObject private var viewModel = InventorySubmissionViewModel()
//    @State var showInventorySubmissionView: Bool = true
    @State private var showChangeView = false
    @State private var reloadView = false
    @State private var showNoChangesAlert = false
    @State private var showEntryTypeAlert = false
    @Environment(\.dismiss) private var dismiss

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
            .fullScreenCover(isPresented: $showChangeView) {
                NavigationStack {
                    InventoryChangeView(showChangeView: $showChangeView, inventorySite: inventorySite)
                    // pass and bind showChangeView variable to the InvenotryChangeView, so that it can change this value
                }
            }
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
                .foregroundColor(Color(UIColor.label)) // Optionally change text color
            }
        }
    }

    private var actionButtonsSection: some View {
        Section {
            confirmExitButton
            confirmContinueButton
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
                    // Dismiss the current view
                    print("confirm & exit")
                    dismiss()
                }
            } else {
                // If counts haven't changed, show an alert
                // ! need to alter this alert to allow for a a confirm with no changes
//                showNoChangesAlert = true
                print("confirm & exit")
                dismiss()
            }
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
            // Perform actions before navigation if needed
            print("confirm & continue")
            // Navigate to the next view
            self.showChangeView = true
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
//    RootView()
    NavigationView {
        InventorySubmissionView(
//            showInventorySubmissionView: .constant(false),
            inventorySite: InventorySite(
                id: "TzLMIsUbadvLh9PEgqaV",
                name: "BCC 122",
                buildingId: "yXT87CrCZCoJVRvZn5DC",
                inventoryTypeIds: ["TzLMIsUbadvLh9PEgqaV"]
            )
        )
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
