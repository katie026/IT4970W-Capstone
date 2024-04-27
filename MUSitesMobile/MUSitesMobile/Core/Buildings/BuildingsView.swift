//
//  BuildingsView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/19/24.
//

import SwiftUI

struct BuildingsView: View {
    
    @StateObject private var viewModel = BuildingsViewModel()
    @State private var searchText = ""
    
    var filteredBuildings: [Building] {
        if searchText.isEmpty {
            return viewModel.buildings
        } else {
            return viewModel.buildings.filter { building in
                building.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding([.horizontal, .top])
            
            List(filteredBuildings) { building in
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Sort by: \(viewModel.selectedSort?.optionLabel ?? "None")") {
                    ForEach(BuildingsViewModel.SortOption.allCases, id: \.self) { option in
                        Button(option.optionLabel) {
                            Task {
                                try? await viewModel.sortSelected(option: option)
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
