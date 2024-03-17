//
//  InventorySubmissionView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/15/24.
//

import SwiftUI

struct InventorySubmissionView: View {
    @StateObject private var viewModel: InventorySubmissionViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    let siteId: String
    let inventoryTypes: [InventoryType]
    
    init(siteId: String, inventoryTypes: [InventoryType]) {
        self.siteId = siteId
        self.inventoryTypes = inventoryTypes
        _viewModel = StateObject(wrappedValue: InventorySubmissionViewModel(inventoryTypes: inventoryTypes))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Inventory Type")) {
                    Picker("Select Inventory Type", selection: $viewModel.selectedInventoryType) {
                        ForEach(viewModel.inventoryTypes, id: \.self) { inventoryType in
                            Text(inventoryType.name).tag(inventoryType)
                        }
                    }
                }
                
                Section(header: Text("Supplies")) {
                    ForEach($viewModel.supplies.indices, id: \.self) { index in
                        let supply = viewModel.supplies[index]
                        HStack {
                            Text(supply.name)
                            
                            Spacer()
                            
                            TextField("Count", value: Binding(
                                get: { viewModel.supplies[index].count ?? 0 },
                                set: { viewModel.supplies[index].count = $0 }
                            ), formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                            
                            Toggle(isOn: Binding(
                                get: { viewModel.supplies[index].confirm ?? false },
                                set: { viewModel.supplies[index].confirm = $0 }
                            )) {
                                Image(systemName: viewModel.supplies[index].confirm == true ? "checkmark.circle.fill" : "circle")
                            }
                            
                            if let fix = viewModel.supplies[index].fix {
                                Text("\(fix)")
                            }
                        }
                    }
                }
                
                Section(header: Text("Comments")) {
                    TextEditor(text: $viewModel.comments)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Submit Inventory")
            .navigationBarItems(trailing: Button(action: {
                viewModel.submitInventory(siteId: siteId) { success in
                    if success {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }) {
                Text("Submit")
            })
        }
    }
}


class InventorySubmissionViewModel: ObservableObject {
    @Published var inventoryTypes: [InventoryType]
    @Published var selectedInventoryType: InventoryType
    @Published var supplies: [Supply] = []
    @Published var comments: String = ""
    
    init(inventoryTypes: [InventoryType]) {
        self.inventoryTypes = inventoryTypes
        if let firstInventoryType = inventoryTypes.first {
            self.selectedInventoryType = firstInventoryType
            self.supplies = firstInventoryType.supplies
        } else {
            self.selectedInventoryType = InventoryType(id: "", name: "", keyTypeId: "", supplies: [])
            self.supplies = []
        }
    }
    
    func submitInventory(siteId: String, completion: @escaping (Bool) -> Void) {
        InventorySubmissionManager.shared.submitInventory(
            siteId: siteId,
            inventoryTypeId: selectedInventoryType.id,
            supplies: supplies,
            comments: comments
        ) { result in
            switch result {
            case .success:
                print("Inventory submission successful")
                completion(true)
            case .failure(let error):
                print("Inventory submission failed: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}

