//
//  TempChangeView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/2/24.
//

import SwiftUI

struct TempChangeView: View {
    // View Model
    @StateObject private var viewModel = InventorySubmissionViewModel()
    // View Control
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    @Binding var parentPresentationMode: PresentationMode
    @State private var reloadView = false
    // Alerts
    @State private var showNoChangesAlert = false
    @State private var showEntryTypeAlert = false
    // Passed-In Constants
    let inventorySite: InventorySite
    
    var body: some View {
//        VStack {
//            Button(action: {
//                self.popParent()
//            }) {
//                Text("Go Back")
//            }
//        }
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
            .navigationTitle("Change Inventory")
            // modifier assigns an identifier to a view
            // if identifer changes, SwiftUI considers the view as having a new identity
            // triggers a view update when reloadView variable changes
            .id(reloadView)
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
                    newSupplyCountsSection
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
        }
    }
    
    private var suppliesSection: some View {
        // List the supplies
        Section(header: Text("Supplies")) {
            // Create grid
            LazyVGrid(columns: [
                GridItem(.flexible(), alignment: .center), // name
//                GridItem(.flexible(), alignment: .center), // old count
                GridItem(.flexible(), alignment: .center), // toggle
                GridItem(.flexible(), alignment: .center), // used
                GridItem(.flexible(), alignment: .center) // new count
            ]) {
                // Grid headers
                Text("Supply").fontWeight(.bold) // nmae
//                Text("Old Count").fontWeight(.bold)  // old count
                Text("Used").fontWeight(.bold) // used
                Text("#").fontWeight(.bold) // used
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
            GridItem(.flexible(), alignment: .center), // toggle
            GridItem(.flexible(), alignment: .center), // used
            GridItem(.flexible(), alignment: .center) // new count
        ]) {

            // supply Name column
            Text(supplyType.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            
//             supply Old Count column
//            Text("\(count)") // old count
            
            // toggle
            HStack {
                Spacer()
                // if there's a supplyCount for the supplyType
                if let supplyCount = supplyCount {
                    // display the toggle
                    usedToggle(for: supplyCount)
                } else {
                    // display placeholder
                    Text("(_)")
                }
                Spacer()
            }
            
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
//                    viewModel.newSupplyCounts[index].usedCount -= 1
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
                        if let newCount = Int(newValue) {
                            // Update the usedCount of the corresponding SupplyCount object
                            viewModel.newSupplyCounts[index].usedCount = newCount
                            // Update the count of the corresponding SupplyCount object
                            viewModel.newSupplyCounts[index].count = (supplyCount.count ?? 0) - newCount
                        }
                    }
                }
            ))
            .multilineTextAlignment(.center)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 50)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            
//            // Plus Button
//            Button(action: {
//                // Increase the used count by 1
//                if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
//                    viewModel.newSupplyCounts[index].usedCount += 1
//                    // Update the count accordingly
//                    viewModel.newSupplyCounts[index].count = (supplyCount.count ?? 0) - viewModel.newSupplyCounts[index].usedCount
//                }
//            }) {
//                Image(systemName: "plus")
//            }
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
        Section(header: Text("New Supply Counts")) {
            // Display the contents of the newSupplyCounts array
            ForEach(viewModel.newSupplyCounts, id: \.id) { supply in
                HStack {
                    Text("ID: \(supply.id)")
                    Text("Used: \(supply.usedCount)")
                    Text("Count: \(supply.count ?? 0)")
                }
                .foregroundColor(Color(UIColor.label))
            }
        }
    }
    
    // Return to DetailedInventorySiteView
    //func popParent() {
}

#Preview {
    NavigationView {
        TempChangeView(
            inventorySite: InventorySite(
                id: "TzLMIsUbadvLh9PEgqaV",
                name: "BCC 122",
                buildingId: "yXT87CrCZCoJVRvZn5DC",
                inventoryTypeIds: ["TzLMIsUbadvLh9PEgqaV"]
            )
        )
    }
}
