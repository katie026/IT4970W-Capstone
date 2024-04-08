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
        HStack(alignment: .top, spacing: 20) {
            // key
            VStack(alignment: .leading, spacing: 4) {
                Text("")
                Text("Used: ")
                Text("Count: ")
                Text("Level: ")
            }
            
            // for each supply type
            ForEach(supplyTypes, id: \.id) { supplyType in
                // find the supply entries for this inventory entry
                if let supplyEntry = viewModel.supplyEntries.first(where: { $0.inventoryEntryId == inventoryEntry.id && $0.supplyTypeId == supplyType.id }) {
                    VStack(alignment: .leading, spacing: 4) {
                        // supply type name
                        Text("**\(supplyType.name)**")
                        
                        // display reported # of used supplies
                        // if supplyEntry.used != nil
                        if let used = supplyEntry.used {
                            // and is not 0
                            if used != 0 {
                                // color red
                                Text("\(used)")
                                    .foregroundColor(Color.red)
                            } else {
                                // otherwise, default color
                                Text("\(used)")
                            }
                        } else {
                            Text("")
                        }
                        
                        // display reported supply count
                        Text("\(supplyEntry.count != nil ? "\(supplyEntry.count!)" : "")")
                        
                        // display reprted level if this supply type collects levels
                        if supplyType.collectLevel == true {
                            // show the supply level or nothing
                            if let level = supplyEntry.level {
                                Text("\(level)%")
                            } else {
                                Text("")
                            }
//                            Text("\(supplyEntry.level != nil ? "\(supplyEntry.level!)%" : "")")
                        } else {
                            // else don't display anything
                            Text("")
                        }
                    }
                // if no supply entries are found for this inventory entry
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("**\(supplyType.name)**")
                        Text("")
                        Text("")
                        Text("")
                    }
                }
            }
            Spacer()
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
            SupplyType(id: "5dbQL6Jmc3ezlsqR75Pu", name: "Color 11x17", notes: "", collectLevel: false),
            SupplyType(id: "B17QKJXEM3oPLaoreQWn", name: "B&W 11x17", notes: "", collectLevel: false),
            SupplyType(id: "SWHMBwzJaR3EggqgWNEk", name: "3M Spray", notes: "", collectLevel: false),
            SupplyType(id: "dpj0LV4bBdw8wRVle7aD", name: "B&W", notes: "", collectLevel: false),
            SupplyType(id: "rGTzAyr1CXN2NV0sapK1", name: "Color Paper", notes: "", collectLevel: false),
            SupplyType(id: "w4V5uYVeF48AvfcgAFN1", name: "Wipes", notes: "", collectLevel: false),
            SupplyType(id: "yOPDkKB4wVEB1dTK9fXy", name: "Paper Towel", notes: "", collectLevel: true),
            SupplyType(id: "pzYHibgLjJ6yjh8T9Jno", name: "Table Spray", notes: "", collectLevel: true)
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
