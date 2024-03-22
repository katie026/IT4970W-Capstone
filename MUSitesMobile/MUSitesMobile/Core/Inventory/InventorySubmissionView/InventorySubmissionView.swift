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
    @Published var comments: String = ""
    
//    func getSupplyCounts(inventorySiteId: String) {
//        Task {
//            self.supplyCounts = try await SupplyCountManager.shared.getAllSupplyCountsBySite(siteId: inventorySiteId)
//        }
//    }
    
    func getSupplyTypes() {
        Task {
            self.supplyTypes = try await SupplyTypeManager.shared.getAllSupplyTypes(descending: true)
        }
    }
    
    func getSupplyCounts(inventorySiteId: String) {
        Task {
            self.supplyCounts = try await SupplyCountManager.shared.getAllSupplyCountsBySite(siteId: inventorySiteId)
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
                // Handle error
                print("Error creating new supply count: \(error)")
            }
        }
    }
    
    // get supply type name for each supply count
//    private func getSupplyCountNames() async throws -> Void {
//        // Iterate through supplyCounts asynchronously
//        for supplyCount in self.supplyCounts {
//            if let typeName = await SupplyCountManager.shared.getSupplyTypeName(supplyTypeId: supplyCount.supplyTypeId ?? "") {
//                // Append non-nil results to the supplyCountNames array
//                self.supplyCountNames.append(typeName)
//            }
//        }
//    }
    
    func submitInventory(inventorySiteId: String, completion: @escaping (Bool) -> Void) {
//        InventorySubmissionManager.shared.submitInventory(
//            siteId: siteId,
//            inventoryTypeId: selectedInventoryType.id,
//            supplies: supplies,
//            comments: comments
//        ) { result in
//            switch result {
//            case .success:
//                print("Inventory submission successful")
//                completion(true)
//            case .failure(let error):
//                print("Inventory submission failed: \(error.localizedDescription)")
//                completion(false)
//            }
//        }
    }
}

struct InventorySubmissionView: View {
    @StateObject private var viewModel = InventorySubmissionViewModel()
    @State private var reloadView = false
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
                    Button("Add") {
                        print("clicked Add button")
                        // create a new SupplyCount in Firestore
                        viewModel.createNewSupplyCount(inventorySiteId: inventorySite.id, supplyTypeId: supplyType.id) {
                            // Reload view upon successful creation
                            reloadView.toggle()
                            print("tried to reload view")
                        }
                    }
                }
                Spacer()
            }
            
            // supply fix field column
            if let supplyCount = supplyCount, !viewModel.newSupplyCounts.contains(where: { $0.id == supplyCount.id }) {
                supplyFixTextField()
            }
        }
        .id(supplyType.id) // Specify the id parameter explicitly
    }

    
    private func supplyToggle(for supplyCount: SupplyCount) -> some View {
        Toggle(isOn: Binding(
            get: { viewModel.newSupplyCounts.contains { $0.id == supplyCount.id } },
            set: { newValue in
                if newValue {
                    let newSupplyCount = SupplyCount(
                        id: supplyCount.id,
                        inventorySiteId: supplyCount.inventorySiteId,
                        supplyTypeId: supplyCount.supplyTypeId,
                        countMin: supplyCount.countMin,
                        count: supplyCount.count
                    )
                    viewModel.newSupplyCounts.append(newSupplyCount)
                } else {
                    viewModel.newSupplyCounts.removeAll { $0.id == supplyCount.id }
                }
            }
        )) {
            
        }
    }
    
    private func supplyFixTextField() -> some View {
        TextField("#", text: .constant(""))
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
//            viewModel.submitInventory(inventorySiteId: inventorySite.id) { success in
//                if success {
//                    presentationMode.wrappedValue.dismiss()
//                }
//            }
        }) {
            Text("Confirm & Exit")
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
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
