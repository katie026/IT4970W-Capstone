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
    
    func getInventoryEntries() {
        Task {
            self.inventoryEntries = try await InventoryEntriesManager.shared.getAllInventoryEntries(descending: true)
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
                VStack {
                    // HEADER
                    headerRow
                    
                    // ENTRIES
                    ForEach(Array(viewModel.inventoryEntries.enumerated()), id: \.element.id) { index, inventoryEntry in
                        entryRow(for: inventoryEntry, index: index)
                    }
                }
            }
        }
        .navigationTitle("Inventory Entries")
        .onAppear {
            Task {
                // if arrays are empty, popoulate them
                viewModel.getInventoryEntries()
            }
        }
    }
    
    private var headerRow: some View {
        LazyVGrid(
            columns: [
                GridItem(.fixed(60), alignment: .center), // index
                GridItem(.fixed(110), alignment: .leading), // date
                GridItem(.fixed(150), alignment: .leading), // user
                GridItem(.fixed(150), alignment: .leading), // site
                GridItem(.fixed(100), alignment: .center), // type
                GridItem(.fixed(100), alignment: .center), // b&w
                GridItem(.fixed(100), alignment: .center), // color
                GridItem(.fixed(100), alignment: .center), // wipes
                GridItem(.fixed(100), alignment: .center), // paper towel
                GridItem(.fixed(100), alignment: .center), // table spray
                GridItem(.fixed(100), alignment: .center), // 3M spray
                GridItem(.fixed(100), alignment: .center), // b&w tabloid
                GridItem(.fixed(100), alignment: .center) // color tabloid
            ],
            spacing: 10
        ) {
            Text("Index").fontWeight(.bold)
            Text("Date").fontWeight(.bold)
            Text("User").fontWeight(.bold)
            Text("Site").fontWeight(.bold)
            Text("Type").fontWeight(.bold)
            Text("B&W Paper").fontWeight(.bold)
            Text("Color Paper").fontWeight(.bold)
            Text("Wipes").fontWeight(.bold)
            Text("Paper Towel").fontWeight(.bold)
            Text("Table Spray").fontWeight(.bold)
            Text("3M Spray").fontWeight(.bold)
            Text("B&W Tabloid").fontWeight(.bold)
            Text("Color Tabloid").fontWeight(.bold)
        }
        .padding(.horizontal)
    }
    
    private func entryRow(for inventoryEntry: InventoryEntry, index: Int) -> some View {
        // 1x13 grid
        LazyVGrid(columns: [
            GridItem(.fixed(60), alignment: .center), // index
            GridItem(.fixed(110), alignment: .leading), // date
            GridItem(.fixed(150), alignment: .leading), // user
            GridItem(.fixed(150), alignment: .leading), // site
            GridItem(.fixed(100), alignment: .center), // type
            GridItem(.fixed(100), alignment: .center), // b&w
            GridItem(.fixed(100), alignment: .center), // color
            GridItem(.fixed(100), alignment: .center), // wipes
            GridItem(.fixed(100), alignment: .center), // paper towel
            GridItem(.fixed(100), alignment: .center), // table spray
            GridItem(.fixed(100), alignment: .center), // 3M spray
            GridItem(.fixed(100), alignment: .center), // b&w tabloid
            GridItem(.fixed(100), alignment: .center) // color tabloid
        ]) {
            // Index
            Text("\(index + 1)")
            // Date
            if let date = inventoryEntry.timestamp {
                Text(dateFormatter.string(from: date))
            }
            // User
            Text("\(inventoryEntry.userId ?? "N/A")")
            // Inventory Site
            Text("\(inventoryEntry.inventorySiteId ?? "N/A")")
            // Entry Type
            Text("\(inventoryEntry.type?.rawValue ?? "N/A")")
            
            // ------- SUPPLIES -------
            // B&W Paper
            Text("\(inventoryEntry.bwPaper.map(String.init) ?? "N/A")")
            // Color Paper
            Text("\(inventoryEntry.colorPaper.map(String.init) ?? "N/A")")
            // Wipes
            Text("\(inventoryEntry.wipes.map(String.init) ?? "N/A")")
            // Paper Towel
            Text("\(inventoryEntry.paperTowel.map(String.init) ?? "N/A")")
            // Table Spray
            Text("\(inventoryEntry.threeMSpray.map(String.init) ?? "N/A")")
            // 3M Spray
            Text("\(inventoryEntry.threeMSpray.map(String.init) ?? "N/A")")
            // B&W Tabloid
            Text("\(inventoryEntry.bwTabloid.map(String.init) ?? "N/A")")
            // Color Tabloid
            Text("\(inventoryEntry.colorTabloid.map(String.init) ?? "N/A")")
        }
    }
}

#Preview {
    NavigationView {
        InventoryEntriesView()
    }
}

/// Simple List Version
//        List {
//            ForEach(Array(viewModel.inventoryEntries.enumerated()), id: \.element.id) { index, inventoryEntry in
//                ScrollView(.horizontal) {
//                    HStack {
//                        // Index
//                        Text("\(index + 1)")
//                        // Date
//                        if let date = inventoryEntry.timestamp {
//                            Text(dateFormatter.string(from: date))
//                        }
//                        // User
//                        Text("UserID: \(inventoryEntry.userId ?? "N/A")")
//                        // Inventory Site
//                        Text("Site: \(inventoryEntry.inventorySiteId ?? "N/A")")
//                        // Entry Type
//                        Text("Type: \(inventoryEntry.type?.rawValue ?? "N/A")")
//
//                        // ------- SUPPLIES -------
//                        // B&W Paper
//                        Text("B&W Paper: \(inventoryEntry.bwPaper.map(String.init) ?? "N/A")")
//                        // Color Paper
//                        Text("Color Paper: \(inventoryEntry.colorPaper.map(String.init) ?? "N/A")")
//                        // Wipes
//                        Text("Wipes: \(inventoryEntry.wipes.map(String.init) ?? "N/A")")
//                        // Paper Towel
//                        Text("Paper Towel: \(inventoryEntry.paperTowel.map(String.init) ?? "N/A")")
//                        // Table Spray
//                        Text("Table Spray: \(inventoryEntry.bwTabloid.map(String.init) ?? "N/A")")
//                        // 3M Spray
//                        Text("3M Spray: \(inventoryEntry.threeMSpray.map(String.init) ?? "N/A")")
//                        // B&W Tabloid
//                        Text("B&W Tabloid: \(inventoryEntry.bwTabloid.map(String.init) ?? "N/A")")
//                        // Color Tabloid
//                        Text("Color Tabloid: \(inventoryEntry.colorTabloid.map(String.init) ?? "N/A")")
//                    }
//                }
//            }
//        }
