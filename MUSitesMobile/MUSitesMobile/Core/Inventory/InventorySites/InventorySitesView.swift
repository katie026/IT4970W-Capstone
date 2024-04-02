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
    @Published private(set) var inventorySiteTest: InventorySite? = nil
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


struct InventorySitesView: View {
    @StateObject private var viewModel = InventorySitesViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.inventorySites) { inventorySite in
                InventorySiteCellView(inventorySite: inventorySite)
            }
//            if let site = viewModel.siteTest {
//                SiteCellView(site: site)
//            }
        }
        .navigationTitle("Inventory Sites")
        .onAppear {
            Task {
                viewModel.getInventorySites()
//                try? await viewModel.getSite(id: "6tYFeMv41IXzfXkwbbh6")
            }
        }
    }
}

#Preview {
    NavigationStack {
        InventorySitesView()
//        RootView()
    }
}
