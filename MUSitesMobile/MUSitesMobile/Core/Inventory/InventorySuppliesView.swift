//
//  InventorySuppliesView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 5/2/24.
//

import SwiftUI

@MainActor
final class InventorySuppliesViewModel: ObservableObject {
    // Supply Values
    @Published var supplyTypes: [SupplyType] = []
    @Published var supplyTypesWithLevels: [SupplyType] = []
    @Published var supplyCounts: [SupplyCount] = []
    // Inventory Sites
    @Published var inventorySites: [InventorySite] = []
    
    func getSupplyTypes() {
        Task {
            self.supplyTypes = try await SupplyTypeManager.shared.getAllSupplyTypes(descending: false)
            self.supplyTypesWithLevels = self.supplyTypes.filter { $0.collectLevel != nil && $0.collectLevel == true }
        }
    }
    
    func getSupplyTypesWithLevels(from supplyTypes: [SupplyType]) -> [SupplyType] {
        // filter supply types where they collect levels
        return supplyTypes.filter { $0.collectLevel != nil && $0.collectLevel == true }
    }

    func getSupplyCounts(inventorySiteId: String) {
        Task {
            self.supplyCounts = try await SupplyCountManager.shared.getAllSupplyCountsBySite(siteId: inventorySiteId)
        }
    }
    
    func getInventorySites(completion: @escaping () -> Void) {
        Task {
            self.inventorySites = try await InventorySitesManager.shared.getAllInventorySites(descending: false)
            completion()
        }
    }
}

struct InventorySuppliesView: View {
    // View Model
    @StateObject private var viewModel = InventorySubmissionViewModel()
    // View Control
    
    // InventorySite
    @State var selectedSite: InventorySite? = nil/*InventorySite(*/
//        id: "TzLMIsUbadvLh9PEgqaV",
//        name: "BCC 122",
//        buildingId: "yXT87CrCZCoJVRvZn5DC",
//        inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]
//        )
    
    var body: some View {
        content
            .navigationTitle("Inventory Supplies")
            .onAppear {
                getSupplyInfo()
            }
    }
    
    var content: some View {
        VStack {
            List {
                sitePicker
                if selectedSite != nil {
                    suppliesSection
                    supplyLevelSection()
                } else {
                    Text("Please select an inventory site to view.")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var suppliesSection: some View {
        // List the supplies
        Section(header: Text("Supply Counts")) {
            // Create 1x2 grid
            LazyVGrid(columns: [
                GridItem(.flexible(), alignment: .center),
                GridItem(.flexible(), alignment: .center)
            ]) {
                // Grid headers
                Text("Supply").fontWeight(.bold)
                Text("Count").fontWeight(.bold)
            }
            
            // if supply types are loaded
            if !viewModel.supplyTypes.isEmpty {
                // given each suppply type, create a row
                ForEach(viewModel.supplyTypes, id: \.id) { supplyType in
                    supplyRow(for: supplyType)
                }
            } else {
                // else show loading circle
                ProgressView()
            }
        }
    }
    
    private func supplyRow(for supplyType: SupplyType) -> some View {
        // find the supply count for the current supply type
        let supplyCount = viewModel.supplyCounts.first(where: { $0.supplyTypeId == supplyType.id })

        // calculate the count, if nil then count = 0
        let count = supplyCount?.count ?? 0

        // create 1x2 grid
        return LazyVGrid(columns: [
            GridItem(.flexible(), alignment: .leading),
            GridItem(.flexible(), alignment: .center)
        ]) {

            // supply name column
            Text(supplyType.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size:15))

            // supply count column
            Text("\(count)")
        }
        // define grid's id
        // when views are recreated due to changes in state/data, id preserves the state of individual views --> ensures user interactions (scrolling/entering text) are maintained correctly across view updates
        .id(supplyType.id) // Specify the id parameter explicitly
    }
    
    private func supplyLevelSection() -> some View {
        var hasSuppliesThatCollectLevel = false
        
        // check each of the supplyTypesWithLevels
        for supplyType in viewModel.supplyTypesWithLevels {
            // look for a SupplyCount in levelSupplyCounts with that supplyTypeId
            if viewModel.levelSupplyCounts.contains(where: { $0.supplyTypeId == supplyType.id }) {
                hasSuppliesThatCollectLevel = true
                break
            }
        }
        
        // if there is a SupplyCount that collects levels
        if (hasSuppliesThatCollectLevel) {
            // show the Supply Levels Section
            let view = Section("Supply Levels") {
                // for each supplyTypesWithLevels
                ForEach(viewModel.supplyTypesWithLevels, id: \.self) { supplyType in
                    // display a slider
                    supplySlider(for: supplyType)
                }
            }
            
            return AnyView(view)
        }
        // return nothing if there aren't any SupplyCounts that collect levels
        return AnyView(EmptyView())
    }
    
    private func supplySlider(for supplyType: SupplyType) -> some View {
        // find the index of the SupplyCount in supplyCounts with supplyTypeId
        guard let supplyCountIndex = viewModel.supplyCounts.firstIndex(where: { $0.supplyTypeId == supplyType.id }) else {
            // if no SupplyCount is found, return an empty view
            return AnyView(EmptyView())
        }
        // get the current level from the supplyCounts list
        let supplyCount = viewModel.supplyCounts[supplyCountIndex]
        
        let slider =  HStack {
            Text("\(supplyType.name)")
                .padding([.horizontal], 5)
            Slider(value: Binding(
                get: {
                    // get the current level from the supplyCounts list
                    let supplyCount = viewModel.supplyCounts[supplyCountIndex]
                    // default to 0 is no level is specified
                    return Double(supplyCount.level ?? 0) // cast the Int into a Double
                },
                set: { newValue in
                    // cast the Double into an Int
                    let intValue = Int(newValue)
                    // update the level in viewModel.levelSupplyCounts
                    viewModel.supplyCounts[supplyCountIndex].level = intValue
                }
            ), in: 0...100)
            .disabled(true) // Disable user interaction with the slider
            Text("\(supplyCount.level ?? 0)%")
        }
        
        // Return the slider
        return AnyView(slider)
    }
    
    private var sitePicker: some View {
        // Site Picker
        Picker("Inventory Site:", selection: $selectedSite) {
            // Option for All sites
            Text("N/A").tag(nil as InventorySite?)
            // Options for each site in Site list
            ForEach(viewModel.inventorySites) { site in
                // dispay the name
                Text(site.name ?? "No Name").tag(site as InventorySite?)
            }
        }.onChange(of: selectedSite) {
            if let selectedSite = selectedSite {
                updateSupplyInfo(inventorySite: selectedSite)
            }
        }
    }
    
    private func getSupplyInfo() {
        // Get supply info
        Task {
            viewModel.getSupplyTypes()
            // Get inventory sites if list is empty
            if (viewModel.inventorySites.isEmpty) {
                // load all inventory sites
                viewModel.getInventorySites {}
            }
        }
    }
    
    private func updateSupplyInfo(inventorySite: InventorySite) {
        // Get supply info
        Task {
            viewModel.getSupplyCounts(inventorySiteId: inventorySite.id)
        }
    }
}

#Preview {
    NavigationView {
        InventorySuppliesView()
    }
}

//InventorySite(
//    id: "TzLMIsUbadvLh9PEgqaV",
//    name: "BCC 122",
//    buildingId: "yXT87CrCZCoJVRvZn5DC",
//    inventoryTypeIds: ["TNkr3dS4rBnWTn5glEw0"]
//    )
