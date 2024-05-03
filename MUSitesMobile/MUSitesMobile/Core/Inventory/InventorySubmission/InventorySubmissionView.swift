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
    @Environment(\.presentationMode) var presentationMode // presentationMode.wrappedValue.dismiss()
    @State private var submissionOver = false
    @State private var goToNextView = false
    @EnvironmentObject var sheetManager: SheetManager // passed-in, for pop up view
    @State private var reloadView = false
    @State private var confirmOption: ConfirmOption = .Exit // button selection
    @State private var submitClicked = false
    @State private var summaryExpanded = false
    // Alerts
    @State private var showDuplicateAlert = false
    
    // Initializer
    let inventorySite: InventorySite
    
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
                        // Get inventory sites if list is empty
                        if (viewModel.inventorySites.isEmpty) {
                            // load all inventory sites
                            viewModel.getInventorySites {
                                // wait for completion
                                // remove the current Site from the list
                                viewModel.inventorySites.removeAll { $0.id == inventorySite.id }
                                // assign a destinationSite
                                if !viewModel.inventorySites.isEmpty {
                                    viewModel.destinationSite = viewModel.inventorySites[0]
                                }
                            }
                        }
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
                                        print("Go to next view")
                                        goToNextView = true
                                        // if user clicked Confirm & Exit
                                    } else {
                                        // dismiss current view
                                        dismissView()
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
                        message: Text("One of these supply counts is the same. Either change or confirm the value."),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .onChange(of: submissionOver) {
                    if submissionOver {
                        dismissView()
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

    private var content: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [.teal, .clear]),
                startPoint: .top,
                endPoint: .center
            )
            .edgesIgnoringSafeArea(.top)
            
            NavigationLink(
                destination: InventoryChangeView(inventorySite: inventorySite, submissionOver: $submissionOver),
                isActive: $goToNextView) {
                    EmptyView()
                }
            
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
                
                // Form section
                Form {
                    suppliesSection
                    supplyLevelSection()
                    commentsSection
                    if viewModel.inventoryEntryType == .MovedFrom {
                        Section("Moves") {
                            destinationSection
                            movedFromSection
                        }
                    } else {
                        Section("Moves") {
                            movedFromSection
                        }
                    }
                    summarySection // for testing
                }
                
                // Action Button section
                actionButtonsSection
            }
        }
    }

    private var suppliesSection: some View {
        // List the supplies
        Section(header: Text("Supply Counts")) {
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
            GridItem(.flexible(), alignment: .leading),
            GridItem(.flexible(), alignment: .center),
            GridItem(.flexible(), alignment: .center),
            GridItem(.flexible(), alignment: .center)
        ]) {

            // supply name column
            Text(supplyType.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size:15))

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
    
    private func supplyLevelSection() -> some View {
        var hasSuppliesThatCollectLevel = false
        
        // check each of the supplyTypesWithLevels
        for supplyType in viewModel.supplyTypesWithLevels {
            // look for a SupplyCount in levelSupplyCounts with that supplyTypeId
            if viewModel.levelSupplyCounts.contains(where: { $0.supplyTypeId == supplyType.id }) {
                hasSuppliesThatCollectLevel = true
                break
            }
        }
        
        // if there is a SupplyCount that collects levels
        if (hasSuppliesThatCollectLevel) {
            // show the Supply Levels Section
            let view = Section("Supply Levels") {
                // for each supplyTypesWithLevels
                ForEach(viewModel.supplyTypesWithLevels, id: \.self) { supplyType in
                    // display a slider
                    supplySlider(for: supplyType)
                }
            }
            
            return AnyView(view)
        }
        // return nothing if there aren't any SupplyCounts that collect levels
        return AnyView(EmptyView())
    }
    
    private func supplySlider(for supplyType: SupplyType) -> some View {
        // find the index of the SupplyCount in levelSupplyCounts with supplyTypeId
        guard let supplyCountIndex = viewModel.levelSupplyCounts.firstIndex(where: { $0.supplyTypeId == supplyType.id }) else {
            // if no SupplyCount is found, return an empty view
            return AnyView(EmptyView())
        }
        
        let slider =  HStack {
            Text("\(supplyType.name)")
                .padding([.horizontal], 5)
            Slider(value: Binding(
                get: {
                    // get the current level from the levelSupplyCounts list
                    let supplyCount = viewModel.levelSupplyCounts[supplyCountIndex]
                    // default to 0 is no level is specified
                    return Double(supplyCount.level ?? 0) // cast the Int into a Double
                },
                set: { newValue in
                    // cast the Double into an Int
                    let intValue = Int(newValue)
                    
                    // update the level in viewModel.levelSupplyCounts
                    viewModel.levelSupplyCounts[supplyCountIndex].level = intValue
                }
            ), in: 0...100)
        }
        
        // Return the slider
        return AnyView(slider)
    }


    private func supplyToggle(for supplyCount: SupplyCount) -> some View {
        // create Confirm toggle
        Toggle(isOn: Binding( // binding establishes two-way connection between view and the underlying data
            // returns boolean binding (toggle state)
            get: {
                // if this supply count exists in newSupplyCounts
                // the .count has not been confirmed, return false
                !viewModel.newSupplyCounts.contains { $0.id == supplyCount.id }
            },
            set: { confirmed in // sets boolean binding (toggle state), receives boolean parameter "confirmed"
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
            // empty toggle label
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
    private var summarySection: some View {
        Section("Summary") {
            DisclosureGroup(isExpanded: $summaryExpanded) {
                // Display the contents of the newSupplyCounts array
                ForEach(viewModel.newSupplyCounts, id: \.id) { supply in
                    // for each SupplyCount in newSupplyCounts
                    HStack {
                        // find the supply type for this supply count
                        if let supplyType = viewModel.supplyTypes.first(where: { $0.id == supply.supplyTypeId }) {
                            // display the supply name
                            Text("\(supplyType.name)").fontWeight(.medium)
                        } else {
                            // if can't find supply type, display the count id
                            Text("ID: \(supply.id)")
                        }
                        Spacer()
                        // NOTE: this does not display the level stored in viewModel.newSupplyCounts, but the level stored in viewModel.levelSupplyCounts (levels are overwritten before updating the DB or creating an inventory entry)
                        if let levelCount = viewModel.levelSupplyCounts.first(where: { $0.id == supply.id }) {
                            Text(levelCount.level != nil ? "Level: \(levelCount.level!)" : "")
                        }
                        Text("Count: \(supply.count != nil ? "\(supply.count!)" : "nil")")
                    }
                    .foregroundColor(Color(UIColor.label))
                }
                
                // Display any SupplyCounts where their levels have been updated, but not their counts (not in newSupplyCounts) -> this reflects what will be sbmitted after merging
                ForEach(viewModel.levelSupplyCounts, id: \.id) { supply in
                    // for each SupplyCount in the levelSupplyCounts
                    // if it doesn't have a corresponding SupplyCount in newSupplyCounts
                    if !viewModel.newSupplyCounts.contains(where: {$0.id == supply.id}) {
                        // find the SupplyCount in the original supplyCounts
                        if let originalCount = viewModel.supplyCounts.first(where: { $0.id == supply.id }) {
                            // if the level has been changed
                            if originalCount.level != supply.level {
                                HStack {
                                    // find the supply type for this supply count
                                    if let supplyType = viewModel.supplyTypes.first(where: { $0.id == supply.supplyTypeId }) {
                                        // display the supply name
                                        Text("\(supplyType.name)").fontWeight(.medium)
                                    } else {
                                        // if can't find supply type, display the count id
                                        Text("ID: \(supply.id)")
                                    }
                                    Spacer()
                                    
                                    // display level from viewModel.levelSupplyCounts
                                    Text(supply.level != nil ? "Level: \(supply.level!)" : "")
                                    
                                    // display count from viewModel.supplyCounts
                                    Text("Count: \(originalCount.count != nil ? "\(originalCount.count!)" : "nil")")
                                }
                            }
                        }
                    }
                }
            } label: {
                Text("Show Summary")
            }
        }
    }
    
    private var movedFromSection: some View {
        // confirm if
        HStack {
            // Label
            Text("Moved supplies from another site: ")
            
            // Toggle
            Toggle(isOn: Binding(
                // returns boolean binding (toggle state)
                get: {
                    // toggle on if type is .MovedFrom
                    viewModel.inventoryEntryType == .MovedFrom
                },
                // sets boolean binding (toggle state)
                set: { toggled in
                    // if toggled on
                    if toggled {
                        viewModel.inventoryEntryType = .MovedFrom
                        // if toggled off
                    } else {
                        viewModel.inventoryEntryType = .Check
                    }
                }
            )) {
                
            }
            Spacer()
        }
        .padding(5)
    }
    
    private var destinationSection: some View {
        // Destination (origin) Site Picker
        Picker("Moved supplies from:", selection: $viewModel.destinationSite) {
            // for each site in InventorySite list
            ForEach(viewModel.inventorySites) { site in
                // dispay the name
                Text(site.name ?? "N/A").tag(site) // tag associates each InventorySite with itself
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
            Text("No Supplies Used")
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
            print("Button confirm continue")
            confirm()
        }) {
            // Button display
            Text("Supplies Used")
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
        print("confirm function start")
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
                dismissView()
            } else {
                // go to next view
                print("Go to next view")
                goToNextView = true
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
                print("Should sheet")
                withAnimation {
                    print("Should withAnimationPresent")
                    sheetManager.present()
                }
            }
        }
    }
    
    func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }
}

//MARK: Previews
//private struct InventorySubmissionPreview: View {
//    @State private var path: [Route] = []
//    
//    private var inventorySite: InventorySite = InventorySite(
//        id: "TzLMIsUbadvLh9PEgqaV",
//        name: "BCC 122",
//        buildingId: "yXT87CrCZCoJVRvZn5DC",
//        inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]
//    )
//    
//    var body: some View {
//        NavigationStack (path: $path) {
//            Button ("Hello World") {
//                path.append(Route.inventorySubmission(inventorySite))
//            }
//            .navigationDestination(for: Route.self) { view in
//                switch view {
//                case .inventorySitesList:
//                    InventorySitesView()
//                case .detailedInventorySite(let inventorySite): DetailedInventorySiteView(path: $path, inventorySite: inventorySite)
//                case .inventorySubmission(let inventorySite):
//                    InventorySubmissionView(path: $path, inventorySite: inventorySite)
//                        .environmentObject(SheetManager())
//                case .inventoryChange(let inventorySite):
//                    InventoryChangeView(path: $path, inventorySite: inventorySite)
//                }
//            }
//        }
//        .onAppear {
//            path.append(Route.inventorySubmission(inventorySite))
//        }
//    }
//}

    
#Preview {
    NavigationStack {
        InventorySubmissionView(inventorySite: InventorySite(
            id: "TzLMIsUbadvLh9PEgqaV",
            name: "BCC 122",
            buildingId: "yXT87CrCZCoJVRvZn5DC",
            inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]
        )
        )
        .environmentObject(SheetManager())
    }
}
