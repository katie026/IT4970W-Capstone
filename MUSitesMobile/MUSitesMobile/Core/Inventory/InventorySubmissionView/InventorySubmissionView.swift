//
//  InventorySubmissionView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/15/24.
//

import SwiftUI

@MainActor
final class InventorySubmissionViewModel: ObservableObject {
    @Published var supplies: [SupplyCount] = []
    @Published var comments: String = ""
    
    func submitInventory(siteId: String, completion: @escaping (Bool) -> Void) {
//            SupplyCountManager.shared.submitInventory(
//                siteId: siteId,
//                inventoryTypeId: selectedInventoryType.id,
//                supplies: supplies,
//                comments: comments
//            ) { result in
//                switch result {
//                case .success:
//                    print("Inventory submission successful")
//                    completion(true)
//                case .failure(let error):
//                    print("Inventory submission failed: \(error.localizedDescription)")
//                    completion(false)
//                }
//            }
    }
}

struct InventorySubmissionView: View {
    @StateObject private var viewModel = InventorySubmissionViewModel()
    @Environment(\.presentationMode) private var presentationMode
    
    let siteId: String
    init(siteId: String) {
        self.siteId = siteId
    }
    
    var body: some View {
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
//                    Section(header: Text("Inventory Type")) {
//                        Picker("Select Inventory Type", selection: $viewModel.selectedInventoryType) {
//                            ForEach(viewModel.inventoryTypes, id: \.self) { inventoryType in
//                                Text(inventoryType.name).tag(inventoryType)
//                            }
//                        }
//                    }
                    
                    Section(header: Text("Supplies")) {
//                        ForEach($viewModel.supplies.indices, id: \.self) { index in
//                            let supply = viewModel.supplies[index]
//                            HStack {
//                                Text(supply.name)
//                                
//                                Spacer()
//                                
//                                TextField("Count", value: Binding(
//                                    get: { viewModel.supplies[index].count ?? 0 },
//                                    set: { viewModel.supplies[index].count = $0 }
//                                ), formatter: NumberFormatter())
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .frame(width: 80)
//                                .multilineTextAlignment(.trailing)
//                                
//                                Toggle(isOn: Binding(
//                                    get: { viewModel.supplies[index].confirm ?? false },
//                                    set: { viewModel.supplies[index].confirm = $0 }
//                                )) {
//                                    Image(systemName: viewModel.supplies[index].confirm == true ? "checkmark.square" : "square")
//                                }
//                                
//                                if let fix = viewModel.supplies[index].fix {
//                                    Text("\(fix)")
//                                }
//                            }
//                        }
                    }
                    
                    Section(header: Text("Comments")) {
                        TextEditor(text: $viewModel.comments)
                            .frame(height: 100)
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            viewModel.submitInventory(siteId: siteId) { success in
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
                        
                        Spacer()
                        
                        Button(action: {
                            // Handle "Confirm & Continue" action
                        }) {
                            Text("Confirm & Continue")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.yellow)
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    NavigationView {
        InventorySubmissionView(siteId: "TzLMIsUbadvLh9PEgqaV")
    }
}
