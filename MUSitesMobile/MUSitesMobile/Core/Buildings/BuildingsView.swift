//
//  BuildingsView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/19/24.
//

import SwiftUI

struct BuildingsView: View {
    
    @StateObject private var viewModel = BuildingsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.buildings) { building in
                BuildingCellView(building: building)
            }
        }
        .navigationTitle("Buildings")
        .toolbar(content: {
            // Sorting
            ToolbarItem(placement: .navigationBarLeading) {
                Menu("Sort by: \(viewModel.selectedSort?.rawValue ?? "NONE")") {
                    ForEach(BuildingsViewModel.SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.sortSelected(option: option)
                            }
                        }
                    }
                }
            }
            
            // Filtering
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Filter: \(viewModel.selectedFilter?.rawValue ?? "NONE")") {
                    ForEach(BuildingsViewModel.FilterOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.filterSelected(option: option)
                            }
                        }
                    }
                }
            }
        })
        .onAppear {
            Task {
                try? await viewModel.getBuildings()
            }
        }
    }
}

#Preview {
    NavigationStack {
        BuildingsView()
    }
}
