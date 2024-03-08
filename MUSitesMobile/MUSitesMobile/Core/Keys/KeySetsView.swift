//
//  KeySetsView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/7/24.
//

import SwiftUI

@MainActor
final class KeySetsViewModel: ObservableObject {
    
    @Published private(set) var keySets: [KeySet] = []
    @Published private(set) var keySetType: KeySet? = nil
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

    func getKeySets() {
        Task {
            self.keySets = try await KeySetManager.shared.getAllKeySets(descending: selectedSort?.sortDescending)
        }
    }
}


struct KeySetsView: View {
    @StateObject private var viewModel = KeySetsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.keySets) { keySet in
                KeySetCellView(keySet: keySet)
            }
        }
        .navigationTitle("Key Sets")
        .onAppear {
            Task {
                viewModel.getKeySets()
            }
        }
    }
}

#Preview {
    NavigationView {
        KeySetsView()
    }
}
