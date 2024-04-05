//
//  InventoryEntriesView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/3/24.
//

import SwiftUI

enum SortOption: String, CaseIterable { // CaseIterable so we can loop through them
    case ascending
    case descending
    
    var sortDescending: Bool? {
        switch self {
        case .ascending: return false
        case .descending: return true
        }
    }
}

@MainActor
final class InventoryEntriesViewModel: ObservableObject {
    
    @Published private(set) var inventoryEntries: [InventoryEntry] = []
    var supplyTypes: [SupplyType] = []
    @Published var supplyEntries: [SupplyEntry] = []
    @Published var selectedSort = SortOption.descending
    @Published var startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @Published var endDate = Date()
    
    // for labels
    var inventorySites: [InventorySite] = []
    var users: [DBUser] = []
    
    func getInventoryEntries(completion: @escaping () async -> Void) {
        Task {
            self.inventoryEntries = try await InventoryEntriesManager.shared.getAllInventoryEntries(descending: selectedSort.sortDescending, startDate: startDate, endDate: endDate)
            await completion()
        }
    }
    
    func swapInventoryEntriesOrder() {
        inventoryEntries.reverse()
    }
    
    func getSupplyTypes() {
        Task {
            self.supplyTypes = try await SupplyTypeManager.shared.getAllSupplyTypes(descending: false)
        }
    }
    
    func getSupplyEntriesForEntry(entryId: String) async -> [SupplyEntry] {
        do {
            return try await SupplyEntriesManager.shared.getAllSupplyEntriesByInventoryEntry(inventoryEntryId: entryId)
        } catch {
            print("Error: \(error)")
            return []
        }
    }
    
    func getSupplyEntriesForAllEntries() async {
        // reset self.supplyEntries list
        self.supplyEntries = []
        
        do {
            // for each inventory entry in self.inventoryEntries
            for inventoryEntry in self.inventoryEntries {
                // try to get list of SupplyEntries
                let someSupplyEntries = try await SupplyEntriesManager.shared.getAllSupplyEntriesByInventoryEntry(inventoryEntryId: inventoryEntry.id)
                
                // if the entry doesn't return any SupplyEntries
                if someSupplyEntries.isEmpty {
                    // try the next inventory entry
                    continue
                } else {
                    // add each SupplyEntry to self.supplyEntries
                    for supplyEntry in someSupplyEntries {
                        self.supplyEntries.append(supplyEntry)
                    }
                }
            }
            print("Got \(self.supplyEntries.count) SupplyEntries for all inventory entries.")
        } catch {
            print("Error getting supply entries: \(error)")
        }
    }
    
    func getInventorySites() async {
        do {
            self.inventorySites = try await InventorySitesManager.shared.getAllInventorySites(descending: nil)
        } catch  {
            print("Error getting inventory sites: \(error)")
        }
    }
    
    func getUsers() async {
        do {
            self.users = try await UserManager.shared.getUsersList()
        } catch  {
            print("Error getting users: \(error)")
        }
    }
}

struct InventoryEntriesView: View {
    // View Model
    @StateObject private var viewModel = InventoryEntriesViewModel()
    // View Control
    @State private var path: [Route] = []
    // Track loading status
    @State private var isLoading = true
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy HH:mm"
        return formatter
    }()
    
    var body: some View {
        // Content
        content
            .navigationTitle("Inventory Entries")
            .onAppear {
                //only really need to load these once per view session
                Task {
                    viewModel.getSupplyTypes()
                    await viewModel.getInventorySites()
                    await viewModel.getUsers()
                }
            }
    }
    
    func fetchEntries() {
        Task {
            // if arrays are empty, populate them
            viewModel.getInventoryEntries {
                print("Got \(viewModel.inventoryEntries.count) inventory entries.")
                await viewModel.getSupplyEntriesForAllEntries()
                isLoading = false
            }
        }
    }
    
    private var content: some View {
        VStack {
            datePickers
            entryList
        }
    }
    
    private var datePickers: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Date Range:")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
                sortButton
                refreshButton
            }.padding([.horizontal, .top])
            
            HStack {
                HStack {
                    DatePicker(
                        "Start Date:",
                        selection: $viewModel.startDate,
                        in: ...viewModel.endDate,
                        displayedComponents: [.date]
                    ).labelsHidden()
                }.padding([.horizontal, .bottom])
                
                Spacer()
                
                Text("to").padding([.horizontal, .bottom])
                
                Spacer()
                
                HStack {
                    DatePicker(
                        "End Date:",
                        selection: $viewModel.endDate,
                        in: viewModel.startDate...Date(),
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                }.padding([.horizontal, .bottom])
            }
        }
    }
    
    private var entryList: some View {
        List {
            ScrollView(.horizontal) {
                ForEach(viewModel.inventoryEntries, id: \.id) { inventoryEntry in
                    HStack(alignment: .top) {
                        InventoryEntryCellView(supplyTypes: viewModel.supplyTypes, inventoryEntry: inventoryEntry, inventorySites: viewModel.inventorySites, users: viewModel.users)
                        
                        SupplyEntriesView(supplyTypes: viewModel.supplyTypes, inventoryEntry: inventoryEntry)
                            .padding(.horizontal)
                        
                        Spacer()
                    }.padding()
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    
    private var refreshButton: some View {
        Button(action: {
            isLoading = true
            fetchEntries()
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20))
        }
    }
    
    private var sortButton: some View {
        Button(action: {
            viewModel.swapInventoryEntriesOrder()
        }) {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 20))
                .padding(.trailing, 10)
        }
    }
}

#Preview {
    NavigationView {
        InventoryEntriesView()
    }
}
