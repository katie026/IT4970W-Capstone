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
    
//    func getInventorySite(id: String) async throws {
//        // Clark ID: 6tYFeMv41IXzfXkwbbh6
//        // use authData to get user data from Firestore as struct
//        self.siteTest = try await SitesManager.shared.getSite(siteId: id)
//    }
//    
//    func sortSelected(option: SortOption) async throws {
//        // set sort option
//        self.selectedSort = option
//        // get sites again
//        self.getSites()
//    }
//    
    func getInventorySites() {
        Task {
            self.inventorySites = try await InventorySitesManager.shared.getAllInventorySites(descending: selectedSort?.sortDescending)
        }
    }
}

enum Route: Hashable {
    case inventorySitesList
    case detailedInventorySite(InventorySite)
    case inventorySubmission(InventorySite)
    case inventoryChange(InventorySite)
}

struct InventorySitesView: View {
    // View Model
    @StateObject private var viewModel = InventorySitesViewModel()
    
    // View Control
    @State private var path: [Route] = []
    
    var body: some View {
        NavigationStack (path: $path) { // will trigger nav destination if $path changes
            List {
//                ForEach(viewModel.inventorySites) { inventorySite in
//                    InventorySiteCellView(inventorySite: inventorySite)
//                }
                ForEach(viewModel.inventorySites) { inventorySite in
                    NavigationLink(value: Route.detailedInventorySite(inventorySite)) {
                        InventorySiteCellView(inventorySite: inventorySite)
                    }
                }
            }
            .navigationTitle("Inventory Sites")
            .onAppear {
                Task {
                    viewModel.getInventorySites()
                    //                try? await viewModel.getSite(id: "6tYFeMv41IXzfXkwbbh6")
                }
            }
            .navigationDestination(for: Route.self) { view in
                switch view {
                case .inventorySitesList:
                    InventorySitesView()
                case .detailedInventorySite(let inventorySite): DetailedInventorySiteView(path: $path, inventorySite: inventorySite)
                case .inventorySubmission(let inventorySite):
                    InventorySubmissionView(path: $path, inventorySite: inventorySite)
                        .environmentObject(SheetManager())
                case .inventoryChange(let inventorySite):
                    InventoryChangeView(path: $path, inventorySite: inventorySite)
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
