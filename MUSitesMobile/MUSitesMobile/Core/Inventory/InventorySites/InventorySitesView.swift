//
//  InventorySitesView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/6/24.
//

import SwiftUI

@MainActor
final class InventorySitesViewModel: ObservableObject {
    
    @Published private(set) var inventorySites: [InventorySite] = []
    @Published var selectedSort: SortOption? = nil
    var inventoryTypes: [InventoryType] = []
    
    //TODO: implement getting building and group info to display
    enum SortOption: String, CaseIterable {
        // CaseIterable so we can loop through them
        case noSort
        case nameAscending
        case nameDescending
        
        var sortDescending: Bool? {
            switch self {
            case .noSort: return nil
            case .nameAscending: return false
            case .nameDescending: return true
            }
        }
    }
    
    enum FilterOption: String, CaseIterable { // may want to relocate this eventually
        // CaseIterable so we can loop through them
        case noFilter
        case hasInventory
        
        var filterKey: String? {
            if self == .noFilter {
                return nil
            }
            return self.rawValue
        }
    }
    
    func getInventorySites() {
        Task {
            self.inventorySites = try await InventorySitesManager.shared.getAllInventorySites(descending: selectedSort?.sortDescending)
        }
    }
    
    func filteredInventorySites(searchText: String) -> [InventorySite] {
        if searchText.isEmpty {
            return inventorySites
        } else {
            return inventorySites.filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
        }
    }
}

struct InventorySitesView: View {
    // View Model
    @StateObject private var viewModel = InventorySitesViewModel()
    @State private var path: [Route] = []
    
    // Search Text
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                TextField("Search", text: $searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                List {
                    ForEach(viewModel.filteredInventorySites(searchText: searchText)) { inventorySite in
                        NavigationLink(destination: DetailedInventorySiteView(path: $path, inventorySite: inventorySite)) {
                            InventorySiteCellView(inventorySite: inventorySite)
                        }
                    }
                }
                .navigationTitle("Inventory Sites")
                .onAppear {
                    viewModel.getInventorySites()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        InventorySitesView()
    }
}
