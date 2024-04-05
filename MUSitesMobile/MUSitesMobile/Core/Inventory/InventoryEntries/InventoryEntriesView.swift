//
//  InventoryEntriesView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/3/24.
//

import SwiftUI

@MainActor
final class InventoryEntriesViewModel: ObservableObject {
    
    @Published private(set) var inventoryEntries: [InventoryEntry] = []
    @Published var supplyTypes: [SupplyType] = []
    @Published var supplyEntries: [SupplyEntry] = []
    
    func getInventoryEntries(completion: @escaping () async -> Void) {
        Task {
            self.inventoryEntries = try await InventoryEntriesManager.shared.getAllInventoryEntries(descending: true)
            await completion()
        }
    }
    
    func getSupplyTypes() {
        Task {
            self.supplyTypes = try await SupplyTypeManager.shared.getAllSupplyTypes(descending: true)
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
    
    // get users [DBUser]
    
    // get inventory sites [InventorySite]
    
    // get supplytypes: [SupplyType]
}

struct InventoryEntriesView: View {
    // View Model
    @StateObject private var viewModel = InventoryEntriesViewModel()
    // View Control
    @State private var path: [Route] = []
    
    // track loading status
    @State private var isLoading = true
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy HH:mm"
        return formatter
    }()
    
    var body: some View {
        // Content
        ScrollView(.horizontal) {
            ScrollView {
                if isLoading {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        Spacer()
                    }
                } else {
                    VStack {
                        // HEADER
                        headerRow
                        
                        // ENTRIES
                        ForEach(viewModel.inventoryEntries.indices, id: \.self) { index in
                            let inventoryEntry = viewModel.inventoryEntries[index]
                            entryRow(for: inventoryEntry, index: index)
                        }
                    }
                }
            }
            .navigationTitle("Inventory Entries")
        }
        .onAppear {
            Task {
                // if arrays are empty, popoulate them
                viewModel.getSupplyTypes()
                viewModel.getInventoryEntries {
                    print("Got \(viewModel.inventoryEntries.count) inventory entries.")
                    await viewModel.getSupplyEntriesForAllEntries()
                    isLoading = false
                }
            }
        }
    }
    
    private var headerRow: some View {
        // Array to store key-value pairs
        var headerArray: [(String, GridItem)] = []

        // Add key-value pairs to the array
        headerArray.append(("Index", GridItem(.fixed(60), alignment: .center)))
        headerArray.append(("Date", GridItem(.fixed(110), alignment: .center)))
        headerArray.append(("User", GridItem(.fixed(150), alignment: .center)))
        headerArray.append(("Site", GridItem(.fixed(150), alignment: .center)))
        headerArray.append(("Type", GridItem(.fixed(100), alignment: .center)))
        headerArray.append(("Comments", GridItem(.fixed(200), alignment: .center)))

        // Add supply columns
        for supplyType in viewModel.supplyTypes {
            headerArray.append((supplyType.name, GridItem(.fixed(100), alignment: .center)))
        }

        // Extract columns and labels from the array of tuples
        let headerColumns = headerArray.map { $0.1 }
        let headerLabels = headerArray.map { $0.0 }
        
        return LazyVGrid(
            columns: headerColumns,
            spacing: 10
        ) {
            ForEach(headerLabels, id: \.self) { label in
                Text(label)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center) // Stretch text to fill column width
            }
        }
        .padding(.horizontal)
    }
    
    private func entryRow(for inventoryEntry: InventoryEntry, index: Int) -> some View {
        // create an array to store key-value pairs
        var entryArray: [(String, GridItem)] = []
        
        // for each header, create a key-value pair (a GridItem and its label)
        // BASIC INFO COLUMNS
        // index
        entryArray.append((String(index), GridItem(.fixed(60), alignment: .center)))
        
        // date
        var dateString = "N/A"
        if let date = inventoryEntry.timestamp {
            dateString = dateFormatter.string(from: date)
        }
        entryArray.append((dateString, GridItem(.fixed(110), alignment: .center)))
        
        // user
        entryArray.append((inventoryEntry.userId ?? "N/A", GridItem(.fixed(150), alignment: .center)))
        // site
        entryArray.append((inventoryEntry.inventorySiteId ?? "N/A", GridItem(.fixed(150), alignment: .center)))
        // type
        entryArray.append((inventoryEntry.type?.rawValue ?? "N/A", GridItem(.fixed(100), alignment: .center)))
        // comments
        entryArray.append((inventoryEntry.comments ?? "N/A", GridItem(.fixed(200), alignment: .center)))
        
        // SUPPLY COUNT COLUMNS
        // find the supplyEntries from this inventoryEntry
        let theseSupplyEntries = viewModel.supplyEntries.filter { $0.inventoryEntryId == inventoryEntry.id }
        print("\(index): \(inventoryEntry.id)")
        // for each supply type
        for supplyType in viewModel.supplyTypes {
            // default display value to "N/A"
            var valueString = "N/A"
            
            //if there's a SupplyEntry for this inventoryEntry where supplyTypeId matches
            if let supplyEntry = theseSupplyEntries.first(where: { $0.supplyTypeId == supplyType.id }) {
                // and if it has a count
                if let count = supplyEntry.count {
                    // update display value
                    valueString = String(count)
                }
            }
            // add key-value pair to the array
            entryArray.append((valueString, GridItem(.fixed(100), alignment: .center)))
            print("\(index) - \(supplyType.name): \(valueString)")
        }
        
        // extract columns and labels from the array of tuples
        let entryLabels = entryArray.map { $0.0 } // list of row values
        let entryColumns = entryArray.map { $0.1 } // list of GridItems for the row
        print("\(index): Create row grid.")
        print("\(index) - labels: \(entryLabels.count), columns: \(entryColumns.count)")
        
        // create a grid and return
        return LazyVGrid(
            columns: entryColumns,
            spacing: 10
        ) {
            ForEach(entryLabels, id: \.self) { label in
                Text(label)
//                    .frame(maxWidth: .infinity, alignment: .center) // Stretch text to fill column width
            }
        }
    }
}

#Preview {
    NavigationView {
        InventoryEntriesView()
    }
}

//// Simple List Version
//var body: some View {
//    List {
//        ForEach(Array(viewModel.inventoryEntries.enumerated()), id: \.element.id) { index, inventoryEntry in
//            ScrollView(.horizontal) {
//                HStack {
//                    // Index
//                    Text("\(index + 1)")
//                    // Date
//                    if let date = inventoryEntry.timestamp {
//                        Text(dateFormatter.string(from: date))
//                    }
//                    // User
//                    Text("UserID: \(inventoryEntry.userId ?? "N/A")")
//                    // Inventory Site
//                    Text("Site: \(inventoryEntry.inventorySiteId ?? "N/A")")
//                    // Entry Type
//                    Text("Type: \(inventoryEntry.type?.rawValue ?? "N/A")")
//
//                    // ------- SUPPLIES -------
//                    ForEach(viewModel.inventoryEntries) { entry in
//                        supplyHStack(for: inventoryEntry)
//                    }
//                    
//                }
//            }
//        }
//    }
//    .navigationTitle("Inventory Entries")
//    .onAppear {
//        Task {
//            // if arrays are empty, popoulate them
//            viewModel.getSupplyTypes()
//            viewModel.getInventoryEntries {
//                print("Got \(viewModel.inventoryEntries.count) inventory entries.")
//                await viewModel.getSupplyEntriesForAllEntries()
//                isLoading = false
//            }
//        }
//    }
//}
