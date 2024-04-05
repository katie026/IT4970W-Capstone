//
//  InventoryChangeView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/1/24.
//

import SwiftUI

struct InventoryChangeView: View {
    // View Model
    @StateObject private var viewModel = InventorySubmissionViewModel()
    // View Control
    @Binding private var path: [Route]
    @State private var reloadView = false
    // Alerts
    @State private var showNoChangesAlert = false
    // init
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
                Task {
                    // Tell the viewModel which site this is
                    viewModel.inventorySite = inventorySite
                    // Get supply info
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
            .navigationTitle("Reduce Inventory")
            // modifier assigns an identifier to a view
            // if identifer changes, SwiftUI considers the view as having a new identity
            // triggers a view update when reloadView variable changes
            .id(reloadView)
            .navigationBarBackButtonHidden(true) // don't let the user go back to InventorySubmissionView
            .onAppear{viewModel.inventoryEntryType = .Use} // default to .Use
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
                
                // Form section
                Form {
                    suppliesSection
                    commentsSection
                    newSupplyCountsSection // for testing
                    entryTypeSection
                    if viewModel.inventoryEntryType == .MoveTo {
                        destinationSection
                    }
                    confirmButton
                }
            }
        }
        // add a button to dismiss keypad when needed
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) { //TODO: test this button
                Button(action: {
                    path.removeLast(path.count - 1)
                }) {
                    Text("Cancel")
                }
            }
        }
    }
    
    private var suppliesSection: some View {
        // List the supplies
        Section(header: Text("Supplies")) {
            // Create grid
            LazyVGrid(columns: [
                GridItem(.flexible(), alignment: .center), // name
//                GridItem(.flexible(), alignment: .center), // old count
//                GridItem(.flexible(), alignment: .center), // toggle
                GridItem(.flexible(), alignment: .center), // used
                GridItem(.flexible(), alignment: .center) // new count
            ]) {
                // Grid headers
                Text("Supply").fontWeight(.bold) // nmae
//                Text("Old Count").fontWeight(.bold)  // old count
//                Text("Used").fontWeight(.bold) // toggle
                Text("Used").fontWeight(.bold) // used
                Text("Count").fontWeight(.bold) // new count
            }
            
            // If supply types are loaded
            if !viewModel.supplyTypes.isEmpty {
                // For each supply type
                ForEach(viewModel.supplyTypes, id: \.id) { supplyType in
                    // create a row
                    supplyRow(for: supplyType)
                }
            } else {
                // else show loading circle
                ProgressView()
            }
        }
    }

    private func supplyRow(for supplyType: SupplyType) -> some View {
        // Find the supply count for the current supply type in viewModel.supplyCounts
        let supplyCount = viewModel.supplyCounts.first(where: { $0.supplyTypeId == supplyType.id })
        // Find the corresponding supply count in viewModel.newSupplyCounts
        let newSupplyCount = viewModel.newSupplyCounts.first(where: { $0.supplyTypeId == supplyType.id })

//        // calculate the count, if nil then count = 0
//        let count = supplyCount?.count ?? 0

        // create grid
        return LazyVGrid(columns: [
            GridItem(.flexible(), alignment: .center), // name
//            GridItem(.flexible(), alignment: .center), // old count
//            GridItem(.flexible(), alignment: .center), // toggle
            GridItem(.flexible(), alignment: .center), // used
            GridItem(.flexible(), alignment: .center) // new count
        ]) {

            // supply Name column
            Text(supplyType.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            
//             supply Old Count column
//            Text("\(count)") // old count
            
//            // toggle
//            HStack {
//                Spacer()
//                // if there's a supplyCount for the supplyType
//                if let supplyCount = supplyCount {
//                    // display the toggle
//                    usedToggle(for: supplyCount)
//                } else {
//                    // display placeholder
//                    Text("(_)")
//                }
//                Spacer()
//            }
            
            // supply Used column
            if let supplyCount = supplyCount, viewModel.newSupplyCounts.contains(where: { $0.id == supplyCount.id }) {
                supplyUsedTextField(for: supplyCount)
            }
            
            // supply New Count column
            if let newSupplyCount = newSupplyCount {
                Text("\(newSupplyCount.count ?? 0)")
            }
        }
        .id(supplyType.id) // Specify the id parameter explicitly
    }
    
    private func usedToggle(for supplyCount: SupplyCount) -> some View {
        // create Used toggle
        Toggle(isOn: Binding( // two-way connection between view and the underlying data
            // returns boolean binding (toggle state)
            get: {
                if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                    if viewModel.newSupplyCounts[index].usedCount >= 0 {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            },
            // sets boolean binding (toggle state)
            // receives boolean parameter "confirmed"
            set: { used in
                // if toggled on
                if used {
                    // if used
                    if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                        // make usedCount positive in newSupplyCounts
                        viewModel.newSupplyCounts[index].usedCount = abs(viewModel.newSupplyCounts[index].usedCount)
                        // update count in newSupplyCounts
                        viewModel.newSupplyCounts[index].count = (supplyCount.count ?? 0) - viewModel.newSupplyCounts[index].usedCount
                    }
                // if toggled off
                } else {
                    // if used
                    if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                        // make usedCount negative in newSupplyCounts
                        viewModel.newSupplyCounts[index].usedCount = -1 * abs(viewModel.newSupplyCounts[index].usedCount)
                        // update count in newSupplyCounts
                        viewModel.newSupplyCounts[index].count = (supplyCount.count ?? 0) - viewModel.newSupplyCounts[index].usedCount
                    }
                }
            }
        )) {

        }
    }
    
    private func supplyUsedTextField(for supplyCount: SupplyCount) -> some View {
        HStack {
//            // Minus Button
//            Button(action: {
//                // Decrease the used count by 1
//                if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
//                    viewModel.newSupplyCounts[index].} -= 1
//                    // Update the count accordingly
//                    viewModel.newSupplyCounts[index].count = (supplyCount.count ?? 0) - viewModel.newSupplyCounts[index].usedCount
//                }
//            }) {
//                Image(systemName: "minus")
//            }
            
            // create Used text field
            TextField("#", text: Binding( // binding establishes two-way connection between view and the underlying data
                // returns boolean binding
                get: {
                    // if the supplyCount is present in the newSupplyCounts array
                    if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                        // display the new count of the supply as a string
                        return "\(viewModel.newSupplyCounts[index].usedCount)"
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
                        if let newUsedCount = Int(newValue) {
                            // find the original count
                            if let originalCount = viewModel.supplyCounts[index].count {
                                // if newUsedCount is <= the originalCount
                                if newUsedCount <= originalCount {
                                    // update the new usedCount
                                    viewModel.newSupplyCounts[index].usedCount = newUsedCount
                                } else {
                                    // otherwsie, set the new usedCount back to 0
                                    viewModel.newSupplyCounts[index].usedCount = 0
                                }
                                // Update the count of the corresponding SupplyCount object
                                viewModel.newSupplyCounts[index].count = (supplyCount.count ?? 0) - newUsedCount
                            }
                        }
                    }
                }
            ))
            .multilineTextAlignment(.center)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 50)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            
            // Plus Button
            Button(action: {
                // find the supply count in newSupplyCounts
                if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                    // find the original count
                    if let originalCount = viewModel.supplyCounts[index].count {
                        // if using <= what is already there
                        if viewModel.newSupplyCounts[index].usedCount + 1 <= originalCount {
                            // increase the used count by 1
                            viewModel.newSupplyCounts[index].usedCount += 1
                        }
                        // update the count accordingly
                        viewModel.newSupplyCounts[index].count = (supplyCount.count ?? 0) - viewModel.newSupplyCounts[index].usedCount
                    }
                }
            }) {
                Image(systemName: "plus")
            }
        }
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
        // Display the contents of the newSupplyCounts array
        Section(header: Text("New Supply Counts")) {
            // for each SupplyCount in newSupplyCounts
            ForEach(viewModel.newSupplyCounts, id: \.id) { supply in
                HStack {
                    // find the supply type for this supply count
                    if let supplyType = viewModel.supplyTypes.first(where: { $0.id == supply.supplyTypeId }) {
                        // display the supply name
                        Text("\(supplyType.name)").fontWeight(.medium)
                    } else {
                        // if can't find supply type, display the count id
                        Text("ID: \(supply.id)")
                    }
                    
                    Text("Count: \(supply.count != nil ? "\(supply.count!)" : "nil")")
                    Text("Level: \(supply.level != nil ? "\(supply.level!)" : "nil")")
                }
                .foregroundColor(Color(UIColor.label))
            }
        }
    }
    
    private var entryTypeSection: some View {
        Section() {
            VStack {
                // Used option
                HStack {
                    RadioButton(text: "Report supplies as used", isSelected: viewModel.inventoryEntryType == .Use) {
                        // these buttons are both triggered when the Section is clicked
                        // toggle between .MoveTo and .Use
                        if viewModel.inventoryEntryType == .Use {
                            viewModel.inventoryEntryType = .MoveTo
                        } else {
                            viewModel.inventoryEntryType = .Use
                        }
                    }
                    Spacer()
                }
                Spacer()
                // Move option
                HStack {
                    RadioButton(text: "Move supplies", isSelected: viewModel.inventoryEntryType == .MoveTo) {
                        // do nothing since both buttons are triggered when the Section is clicked
                    }
                    Spacer()
                }
            }
            .padding()
        }
    }
    
    private var destinationSection: some View {
        // Destination Site Picker
        Picker("Move to:", selection: $viewModel.destinationSite) {
            // for each site in InventorySite list
            ForEach(viewModel.inventorySites) { site in
                // dispay the name
                Text(site.name ?? "N/A").tag(site) // tag associates each InventorySite with itself
            }
        }
    }
    
    private var confirmButton: some View {
        Section() {
            HStack {
                Spacer()
                // Confirm Button
                Button(action: {
                    // if no supplies are reported used
                    if viewModel.newSupplyCounts.allSatisfy({ $0.usedCount == 0 }) {
                        // show an alert
                        showNoChangesAlert = true
                    // otherwise, some supplies have been used
                    } else {
                        // submit inventory entry & update supplyCounts
                        print("Submit entry as \(viewModel.inventoryEntryType).")
                        viewModel.submitAnInventoryEntry() { print("Entry completion.") }
                        
                        // return to DetailedInventoryView
                        path.removeLast(path.count - 1)
                    }
                }) {
                    // Label
                    Spacer()
                    Text("Submit")
                        .background(Color.yellow)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                }
                Spacer()
            }
        }
        .alert(isPresented: $showNoChangesAlert) {
            Alert(
                title: Text("No Supplies Changed"),
                message: Text("You have not reported any supplies being used/moved."),
                primaryButton: .default(Text("Try Again")) {
                    // dismiss alert
                    showNoChangesAlert = false
                },
                secondaryButton: .destructive(Text("Cancel Submission")) {
                    // return to DetailedInventoryView
                    path.removeLast(path.count - 1)
                }
            )
        }
    }
}

//MARK: Previews
private struct InventoryChangePreview: View {
    @State private var path: [Route] = []
    
    private var inventorySite: InventorySite = InventorySite(
        id: "TzLMIsUbadvLh9PEgqaV",
        name: "GO BCC",
        buildingId: "yXT87CrCZCoJVRvZn5DC",
        inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]
    )
    
    var body: some View {
        NavigationStack (path: $path) {
            Button ("Hello World") {
                path.append(Route.inventoryChange(inventorySite))
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
            path.append(Route.inventoryChange(inventorySite))
        }
    }
}

    
#Preview {
    InventoryChangePreview()
}
