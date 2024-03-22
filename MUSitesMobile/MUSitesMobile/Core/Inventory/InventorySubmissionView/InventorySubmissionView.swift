//
//  InventorySubmissionView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/15/24.
//

import SwiftUI

@MainActor
final class InventorySubmissionViewModel: ObservableObject {
    @Published var supplyCounts: [SupplyCount] = []
    @Published var newSupplyCounts: [SupplyCount] = [] // Change to SupplyCount array
    @Published var supplyCountNames: [String] = []
    @Published var comments: String = ""
    
//    func getSupplyCounts(inventorySiteId: String) {
//        Task {
//            self.supplyCounts = try await SupplyCountManager.shared.getAllSupplyCountsBySite(siteId: inventorySiteId)
//        }
//    }
    
    func getSupplyCounts(inventorySiteId: String) {
        Task {
            self.supplyCounts = try await SupplyCountManager.shared.getAllSupplyCountsBySite(siteId: inventorySiteId)
            // Populate supplyCountNames array
            try await getSupplyCountNames()
        }
    }
    
    // get supply type name for each supply count
    private func getSupplyCountNames() async throws -> Void {
        // Iterate through supplyCounts asynchronously
        for supplyCount in self.supplyCounts {
            if let typeName = await SupplyCountManager.shared.getSupplyTypeName(supplyTypeId: supplyCount.supplyTypeId ?? "") {
                // Append non-nil results to the supplyCountNames array
                self.supplyCountNames.append(typeName)
            }
        }
    }
    
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
    @Environment(\.presentationMode) private var presentationMode
    
    let inventorySite: InventorySite
    
    var body: some View {
        content
            .onAppear {
                Task {
                    viewModel.getSupplyCounts(inventorySiteId: inventorySite.id)
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
            // wait for supply names to load
            if viewModel.supplyCounts.count == viewModel.supplyCountNames.count {
                ForEach(viewModel.supplyCounts.indices, id: \.self) { index in
                    supplyRow(for: viewModel.supplyCounts[index], supplyCountName: viewModel.supplyCountNames[index])
                }
            } else {
                ProgressView()
            }
        }
    }
    
    private func supplyRow(for supplyCount: SupplyCount, supplyCountName: String) -> some View {
        // create 1x4 grid
        LazyVGrid(columns: [
            GridItem(.flexible(), alignment: .center),
            GridItem(.flexible(), alignment: .center),
            GridItem(.flexible(), alignment: .center),
            GridItem(.flexible(), alignment: .center)
        ]) {
            
            // supply name column
            Text(supplyCountName)
                .frame(maxWidth: .infinity, alignment: .leading) // Align text to the leading edge
            
            // supply count column
            supplyCountText(for: supplyCount)
            
            // supply toggle column
            HStack {
                Spacer()
                supplyToggle(for: supplyCount)
                Spacer()
            }
            
            // supply fix field column
            if !viewModel.newSupplyCounts.contains(where: { $0.id == supplyCount.id }) {
                supplyFixTextField()
            }
        }
    }
    
    private func supplyCountText(for supplyCount: SupplyCount) -> some View {
        if let count = supplyCount.count {
            return AnyView(Text(String(count)))
        } else {
            return AnyView(Text("N/A"))
        }
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
