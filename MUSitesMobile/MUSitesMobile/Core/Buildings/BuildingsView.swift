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
        //testing button for the buildingId query
        Button("Fetch Building") {
            viewModel.fetchBuilding(withID: "4NqNXGqU9iItZaVg3V2h")
        }
        if let building = viewModel.building {
            Text("Building Name: \(building.name ?? "Unknown")")
        }
        //end of test
        List {
            ForEach(viewModel.buildings) { building in
                BuildingCellView(building: building)
                    .contextMenu {
                        Button("Add to Tasks") {
                            viewModel.addUserBuilding(buildingId: building.id)
                        }
                    }
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
                viewModel.getBuildings()
            }
        }
    }
}

#Preview {
    NavigationStack {
        BuildingsView()
    }
}
