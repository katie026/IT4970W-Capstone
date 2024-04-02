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
    @State private var reloadView = false
    // Alerts
    @State private var showNoChangesAlert = false
    @State private var showEntryTypeAlert = false
    // Pased-In Constants
    let inventorySite: InventorySite
    
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
                GridItem(.flexible(), alignment: .center),
//                GridItem(.flexible(), alignment: .center), // old count
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center)
            ]) {
                // Grid headers
                Text("Supply").fontWeight(.bold)
//                Text("Old Count").fontWeight(.bold)  // old count
                Text("Used").fontWeight(.bold)
                Text("Count").fontWeight(.bold) // new count
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
        // Find the supply count for the current supply type in viewModel.supplyCounts
        let supplyCount = viewModel.supplyCounts.first(where: { $0.supplyTypeId == supplyType.id })
        // Find the corresponding supply count in viewModel.newSupplyCounts
        let newSupplyCount = viewModel.newSupplyCounts.first(where: { $0.supplyTypeId == supplyType.id })

        // calculate the count, if nil then count = 0
        let count = supplyCount?.count ?? 0
        let usedCount = supplyCount?.usedCount ?? 0

        // create grid
        return LazyVGrid(columns: [
            GridItem(.flexible(), alignment: .center),
//            GridItem(.flexible(), alignment: .center), // old count
            GridItem(.flexible(), alignment: .center),
            GridItem(.flexible(), alignment: .center)
        ]) {

            // supply Name column
            Text(supplyType.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // supply Old Count column
//            Text("\(count)") // old count
            
            // supply Used column
            if let supplyCount = supplyCount, viewModel.newSupplyCounts.contains(where: { $0.id == supplyCount.id }) {
                supplyUsedTextField(for: supplyCount)
                
            }
            
            // supply New Count column
            if let newSupplyCount = newSupplyCount {
                Text("\(newSupplyCount.count ?? 0)")
            }
        }
        // define grid's id
        // when views are recreated due to changes in state/data, id preserves the state of individual views --> ensures user interactions (scrolling/entering text) are maintained correctly across view updates
        .id(supplyType.id) // Specify the id parameter explicitly
    }
    
    private func supplyUsedTextField(for supplyCount: SupplyCount) -> some View {
        HStack {
            // Minus Button
            Button(action: {
                // Decrease the used count by 1
                if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                    viewModel.newSupplyCounts[index].usedCount -= 1
                    // Update the count accordingly
                    viewModel.newSupplyCounts[index].count = (supplyCount.count ?? 0) - viewModel.newSupplyCounts[index].usedCount
                }
                print("minus")
            }) {
                Image(systemName: "minus")
            }
            
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
            
            // Plus Button
            Button(action: {
                // Increase the used count by 1
                if let index = viewModel.newSupplyCounts.firstIndex(where: { $0.id == supplyCount.id }) {
                    viewModel.newSupplyCounts[index].usedCount += 1
                    // Update the count accordingly
                    viewModel.newSupplyCounts[index].count = (supplyCount.count ?? 0) - viewModel.newSupplyCounts[index].usedCount
                }
                print("plus")
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

// MARK: Structs for Preview

private struct ParentPresentationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationLink("Confirm & Continue",
                       destination: InventoryChangeView(
                        parentPresentationMode: self.presentationMode,
                        inventorySite: InventorySite(
                            id: "TzLMIsUbadvLh9PEgqaV",
                            name: "BCC 122",
                            buildingId: "yXT87CrCZCoJVRvZn5DC",
                            inventoryTypeIds: ["TzLMIsUbadvLh9PEgqaV"]
                        )
                       )
        )
    }
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
