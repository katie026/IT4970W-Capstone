//
//  SupplyEntriesView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/4/24.
//

import SwiftUI

@MainActor
final class SupplyEntriesViewModel: ObservableObject {
    
}

struct SupplyEntriesView: View {
    // View Model
    @StateObject private var viewModel = InventoryEntriesViewModel()
    
    let supplyTypes: [SupplyType]
    let inventoryEntry: InventoryEntry
    
    var body: some View {
        HStack(spacing: 20) {
            // key
            VStack(alignment: .leading, spacing: 4) {
                Text("")
                Text("Used: ")
                Text("Count: ")
                Text("Level: ")
            }
            
            // for each supply
            ForEach(supplyTypes, id: \.id) { supplyType in
                if let supplyEntry = viewModel.supplyEntries.first(where: { $0.inventoryEntryId == inventoryEntry.id && $0.supplyTypeId == supplyType.id }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("**\(supplyType.name)**")
                        // if supply was used
                        if let used = supplyEntry.used {
                            // and is greater than 0
                            if used > 0 {
                                // color red
                                Text("\(used)")
                                    .foregroundColor(Color.red)
                            } else {
                                // otherwise, default color
                                Text("\(used)")
                            }
                        } else {
                            Text("-")
                        }
//                        Text("\(supplyEntry.used != nil ? "\(supplyEntry.used!)" : "-")")
                        Text("\(supplyEntry.count != nil ? "\(supplyEntry.count!)" : "-")")
                        Text("\(supplyEntry.level != nil ? "\(supplyEntry.level!)%" : "-")")
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("**\(supplyType.name)**")
                        Text("-")
                        Text("-")
                        Text("-")
                    }
                }
            }
        }
        .onAppear {
            Task {
                viewModel.supplyEntries = await viewModel.getSupplyEntriesForEntry(entryId: inventoryEntry.id)
            }
        }
    }
}

#Preview {
    SupplyEntriesView(
        supplyTypes: [
            SupplyType(id: "5dbQL6Jmc3ezlsqR75Pu", name: "Color 11x17", notes: ""),
            SupplyType(id: "B17QKJXEM3oPLaoreQWn", name: "B&W 11x17", notes: ""),
            SupplyType(id: "SWHMBwzJaR3EggqgWNEk", name: "3M Spray", notes: ""),
            SupplyType(id: "dpj0LV4bBdw8wRVle7aD", name: "B&W", notes: ""),
            SupplyType(id: "rGTzAyr1CXN2NV0sapK1", name: "Color Paper", notes: ""),
            SupplyType(id: "w4V5uYVeF48AvfcgAFN1", name: "Wipes", notes: ""),
            SupplyType(id: "yOPDkKB4wVEB1dTK9fXy", name: "Paper Towel", notes: "")
        ]
        ,
        inventoryEntry: InventoryEntry(
            id: "BhMOtDzIS0QLC4ELMPLm",
            inventorySiteId: "NhuQrCUj5wz0XwMWoe7m",
            timestamp: Date(),
            type: .Fix,
            userId: "Katie1234",
            comments: "Commenting here. Moved some stuff."
        )
    )
}
