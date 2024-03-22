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
    @Published var comments: String = ""
    
    func getSupplyCounts(inventorySiteId: String) {
        Task {
            self.supplyCounts = try await SupplyCountManager.shared.getAllSupplyCountsBySite(siteId: inventorySiteId)
        }
        print("init: \(supplyCounts.count)")
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
    }
    
    private var suppliesSection: some View {
        Section(header: Text("Supplies")) {
            ForEach(viewModel.supplyCounts) { supplyCount in
                supplyRow(for: supplyCount)
            }
        }
    }
    
    private func supplyRow(for supplyCount: SupplyCount) -> some View {
        HStack {
            Text(supplyCount.supplyTypeId ?? "N/A")
            Spacer()
            supplyCountText(for: supplyCount)
            supplyToggle(for: supplyCount)
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
            Image(systemName: viewModel.newSupplyCounts.contains { $0.id == supplyCount.id } ? "checkmark.square" : "square")
        }
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
            viewModel.submitInventory(inventorySiteId: inventorySite.id) { success in
                if success {
                    presentationMode.wrappedValue.dismiss()
                }
            }
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
