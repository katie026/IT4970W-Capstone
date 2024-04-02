//
//  InventorySubmissionView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/15/24.
//

import SwiftUI

struct InventorySubmissionView: View {
    // View Model
    @StateObject private var viewModel = InventorySubmissionViewModel()
    // View Controls
    @State private var reloadView = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var sheetManager: SheetManager
    // Alerts
    @State private var showNoChangesAlert = false
    @State private var showEntryTypeAlert = false
    @State private var inventoryEntryType: InventoryEntryType = .Check
    // Passed-In Constants
    let inventorySite: InventorySite
    
    // Main Content
    var body: some View {
        // Content
        content
            // On appear
            .onAppear {
                // Get supply info
                Task {
                    viewModel.getSupplyCounts(inventorySiteId: inventorySite.id)
                    viewModel.getSupplyTypes()
                }
            }
            // View Title
            .navigationTitle("Submit Inventory")
            // modifier assigns an identifier to a view
            // if identifer changes, SwiftUI considers the view as having a new identity
            // triggers a view update when reloadView variable changes
            .id(reloadView)
            .overlay(alignment: .bottom) {
                if sheetManager.action.isPresented {
                    EntryTypePopupView(didClose: {
                        withAnimation {
                            sheetManager.dismiss()
                        }
                    }, selectedOption: $inventoryEntryType)
                }
            }
    }

    private var content: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [.teal, .clear]),
                startPoint: .top,
                endPoint: .center
            )
            .edgesIgnoringSafeArea(.top)
            
            // Content window
            VStack() {
                // Subtitle
                HStack {
                    Text(inventorySite.name ?? "No name")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.horizontal)
                    Spacer()
                }
                
                // Testing purposes
                Button("Show Custom Sheet") {
                    withAnimation {
                        sheetManager.present()
                    }
                }
                Text("\(inventoryEntryType)")
                
                // Form section
                Form {
                    suppliesSection
                    commentsSection
                    newSupplyCountsSection
                }
                
                // Action Button section
                actionButtonsSection
            }
        }
        // add a button to dismiss keypad when needed
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
    }

    private var suppliesSection: some View {
        // List the supplies
        Section(header: Text("Supplies")) {
            // Create 1x4 grid
            LazyVGrid(columns: [
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center)
            ]) {
                // Grid headers
                Text("Supply").fontWeight(.bold)
                Text("Count").fontWeight(.bold)
                Text("Confirm").fontWeight(.bold)
                Text("Fix").fontWeight(.bold)
            }
            
            // If supply types are loaded
            if !viewModel.supplyTypes.isEmpty {
                // given each suppply type, create a row
                ForEach(viewModel.supplyTypes, id: \.id) { supplyType in
                    supplyRow(for: supplyType)
                }
            } else {
                // else show loading circle
                ProgressView()
            }
        }
    }

    private func supplyRow(for supplyType: SupplyType) -> some View {
        // find the supply count for the current supply type
        let supplyCount = viewModel.supplyCounts.first(where: { $0.supplyTypeId == supplyType.id })

        // calculate the count, if nil then count = 0
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
        // define grid's id
        // when views are recreated due to changes in state/data, id preserves the state of individual views --> ensures user interactions (scrolling/entering text) are maintained correctly across view updates
        .id(supplyType.id) // Specify the id parameter explicitly
    }


    private func supplyToggle(for supplyCount: SupplyCount) -> some View {
        // create Confirm toggle
        Toggle(isOn: Binding( // binding establishes two-way connection between view and the underlying data
            // returns boolean binding (toggle state)
            get: {
                // closure that returns the value of the boolean binding
                // invoked whenever the value of the binding is accessed
                //  if newSupplyCounts array contains an element with the same supplyCount ID -> turn toggle "off" (returns false) else turn toggle "on" (return true)
                !viewModel.newSupplyCounts.contains { $0.id == supplyCount.id }
            },
            // sets boolean binding (toggle state)
            // receives boolean parameter "confirmed"
            set: { confirmed in
                // if toggled on
                if confirmed {
                    // If confirmed, remove from newSupplyCounts if exists
                    if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                        viewModel.newSupplyCounts.remove(at: index)
                    }
                // if toggled off
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
        // create Fix text field
        TextField("#", text: Binding( // binding establishes two-way connection between view and the underlying data
            // returns boolean binding
            get: {
                // if the supplyCount is present in the newSupplyCounts array
                if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                    // display the new count of the supply as a string
                    return "\(viewModel.newSupplyCounts[index].count ?? 0)"
                } else {
                    // otherwise, return an empty string
                    return ""
                }
            },
            // sets boolean binding, called when the TextField value is changed
            set: { newValue in
                // if the supplyCount is present in the newSupplyCounts array
                if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                    // Parse the new value as an integer
                    if let newCount = Int(newValue) {
                        // Update the new count of the corresponding SupplyCount object
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
            // craete large text field
            TextEditor(text: $viewModel.comments)
                .frame(height: 100)
        }
    }
    
    // list of NewSupplyCounts for testing purposes
    private var newSupplyCountsSection: some View {
        Section(header: Text("New Supply Counts")) {
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
        // Section for action buttons
        Section {
            HStack {
                // Confirm & Exit back to DetailedInventorySiteView
                confirmExitButton
                Text("OR")
                // Confirm & Continue to IvnentoryChangeVIew
                confirmContinueButton
            }
            .padding(.vertical)
        }
    }

    private var confirmExitButton: some View {
        // Confirm & Exit button
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
                viewModel.submitSupplyCounts() { // this code excutes immediately (doesn't wait for async)
//                    reloadView.toggle() // reloads view
                    // Dismiss the current view
                    print("counts changed: confirm & exit")
                    dismiss()
                }
            } else {
                // If counts haven't changed
                // upadte entry type
                inventoryEntryType = .Check
                // show an alert
                showNoChangesAlert = true
            }
        }) {
            Text("Confirm & Exit")
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
        .alert(isPresented: $showNoChangesAlert) {
            Alert(
                title: Text("No Changes"),
                message: Text("There are no changes to submit."),
                // OK Button
                primaryButton: .default(Text("OK")) {
                    // submit the counts anyway
                    viewModel.submitSupplyCounts() { // this code excutes immediately (doesn't wait for async)
                        // Dismiss the current view
                        print("counts not changed: confirm & exit")
                        dismiss()
                    }
                },
                // Cancel Button
                secondaryButton: .cancel()
            )
        }
    }
    
    private var confirmContinueButton: some View {
        // Confirm & Continue button
        NavigationLink(destination: InventoryChangeView(
            parentPresentationMode: self.presentationMode,
            inventorySite: inventorySite)
        ) {
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
        InventorySubmissionView(
            inventorySite: InventorySite(
                id: "TzLMIsUbadvLh9PEgqaV",
                name: "BCC 122",
                buildingId: "yXT87CrCZCoJVRvZn5DC",
                inventoryTypeIds: ["TzLMIsUbadvLh9PEgqaV"]
            )
        )
        .environmentObject(SheetManager())
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
