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
    @Binding private var path: [Route] // passed-in
    @EnvironmentObject var sheetManager: SheetManager // passed-in, for pop up view
    @State private var reloadView = false
    @State private var confirmOption: ConfirmOption = .Exit // button selection
    @State private var submitClicked = false
    // Alerts
    @State private var showDuplicateAlert = false
    
    // Initializer
    let inventorySite: InventorySite
    init(path: Binding<[Route]>, inventorySite: InventorySite) {
        self._path = path
        self.inventorySite = inventorySite
    }
    
    var body: some View {
        // Content
        content
            // On appear
            .onAppear {
                // tell the viewModel which inventorySite this is
                viewModel.inventorySite = inventorySite
                // Get supply info
                Task {
                    viewModel.getSupplyCounts(inventorySiteId: inventorySite.id)
                    viewModel.getSupplyTypes()
                }
            }
            // View Title
            .navigationTitle("Submit Inventory")
            // Assign id to view
            .id(reloadView) // triggers update when reloadView changes
            // EntryType Popup
            .overlay(alignment: .bottom) {
                // when sheetManager.present() is called -> sheetManager's enum Action == .isPresented
                if sheetManager.action.isPresented {
                    // overlay the PopupView
                    EntryTypePopupView(
                        // pass in closure
                        didClose: { // after closure is called
                            // if SUBMIT was clicked
                            if submitClicked {
                                // submit an entry
                                print("Submit entry as \(viewModel.inventoryEntryType).")
                                viewModel.submitAnInventoryEntry() { print("Entry completion.") }
                                
                                // reset submitClicked status
                                submitClicked = false
                                
                                // dismiss popup
                                withAnimation {
                                    sheetManager.dismiss()
                                }
                                
                                // if user clicked Confirm & Continue
                                if confirmOption == .Continue {
                                    // go to next view
                                    path.append(Route.inventoryChange(inventorySite))
                                // if user clicked Confirm & Exit
                                } else {
                                    // dismiss current view
                                    path.removeLast()
                                }
                            } else {
                            // if CLOSE was clicked
                                // dismiss popup
                                withAnimation {
                                    sheetManager.dismiss()
                                }
                            }
                        },
                        // pass in entryType
                        selectedOption: $viewModel.inventoryEntryType,
                        // pass in submitClicked bool
                        submitClicked: $submitClicked)
                }
            }
            .alert(isPresented: $showDuplicateAlert) {
                Alert(
                    title: Text("Duplicate Count"),
                    message: Text("One of these supplie counts is the same. Either change or confirm the value."),
                    dismissButton: .default(Text("OK"))
                )
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
                Text("\(viewModel.inventoryEntryType)") // for testing
                Text("\(viewModel.inventorySite?.name ?? "nil")") // for testing
                
                // Form section
                Form {
                    suppliesSection
                    commentsSection
                    newSupplyCountsSection // for testing
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
            
            // if supply types are loaded
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
            // if this supplyCount is in the newSupplyCounts array
            if let supplyCount = supplyCount, viewModel.newSupplyCounts.contains(where: { $0.id == supplyCount.id }) {
                // display the text field
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
                // if toggled on (confirmed)
                if confirmed {
                    // remove supplyCount from newSupplyCounts array if exists
                    if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                        viewModel.newSupplyCounts.remove(at: index)
                    }
                // if toggled off (not confirmed)
                } else {
                    // add supplyCount to newSupplyCounts if not already added
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
                .foregroundColor(Color(UIColor.label))
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
            // indicate which button was pressed
            confirmOption = .Exit
            confirm()
        }) {
            // Button display
            Text("Confirm & Exit")
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
    
    private var confirmContinueButton: some View {
        // Confirm & Continue button
        Button(action: {
            // indicate which button was pressed
            confirmOption = .Continue
            confirm()
        }) {
            // Button display
            Text("Confirm & Continue")
                .foregroundColor(.white)
                .padding()
                .background(Color.yellow)
                .cornerRadius(10)
        }
    }
    
    private enum ConfirmOption {
        case Continue
        case Exit
    }
    
    private func confirm() {
        // check if newSupplyCounts is empty
        var allTogglesConfirmed = false
        if viewModel.newSupplyCounts.isEmpty {
            allTogglesConfirmed = true
        }

        // if all toggles are confirmed (newSupplyTypes is empty)
        if allTogglesConfirmed {
            // update entry type
            viewModel.inventoryEntryType = .Check
            
            // submit an entry
            print("Submit entry as \(viewModel.inventoryEntryType).")
            viewModel.submitAnInventoryEntry() { print("Entry completion.") }
            
            if confirmOption == .Exit {
                // dismiss submission view
                path.removeLast()
            } else {
                // go to next view
                path.append(Route.inventoryChange(inventorySite))
            }
        // if any toggles are false (newSupplyTypes has data)
        } else {
            // check if any newSupplyCounts match the original supplyCounts
            var hasDuplicateCount = false
            // for each newSupplyCount
            for newSupplyCount in viewModel.newSupplyCounts {
                // if original supplyCounts has a SupplyCount that matches the newSupplyCount
                if viewModel.supplyCounts.contains(where: { $0.supplyTypeId == newSupplyCount.supplyTypeId && $0.count == newSupplyCount.count }) {
                    hasDuplicateCount = true
                    break
                }
            }
            
            // if any newSupplyCount matches the original supplyCount
            if hasDuplicateCount {
                // show alert
                showDuplicateAlert = true
            // otherwise, the user entered intentional changes
            } else {
                // display popup -> update entry type (.Fix or .Delivery) -> may submit entry
                withAnimation {
                    sheetManager.present()
                }
            }
        }
    }
}

//MARK: Previews
private struct InventorySubmissionPreview: View {
    @State private var path: [Route] = []
    
    private var inventorySite: InventorySite = InventorySite(
        id: "TzLMIsUbadvLh9PEgqaV",
        name: "BCC 122",
        buildingId: "yXT87CrCZCoJVRvZn5DC",
        inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]
    )
    
    var body: some View {
        NavigationStack (path: $path) {
            Button ("Hello World") {
                path.append(Route.inventorySubmission(inventorySite))
            }
            .navigationDestination(for: Route.self) { view in
                switch view {
                case .inventorySitesList:
                    InventorySitesView()
                case .detailedInventorySite(let inventorySite): DetailedInventorySiteView(path: $path, inventorySite: inventorySite)
                case .inventorySubmission(let inventorySite):
                    InventorySubmissionView(path: $path, inventorySite: inventorySite)
                        .environmentObject(SheetManager())
                case .inventoryChange(let inventorySite):
                    InventoryChangeView(path: $path, inventorySite: inventorySite)
                }
            }
        }
        .onAppear {
            path.append(Route.inventorySubmission(inventorySite))
        }
    }
}

    
#Preview {
    InventorySubmissionPreview()
}
