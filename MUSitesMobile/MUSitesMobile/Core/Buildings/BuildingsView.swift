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
            NavigationView {
                VStack {
                    TextField("Search", text: $searchText)
                        .padding(.horizontal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                    
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
                    
                    // Filtering - Removed for Search
                    
                    // You can keep other toolbar items here if needed
                })
                .onAppear {
                    Task {
                        viewModel.getBuildings()
                    }
                }
            }
        }
}

#Preview {
    NavigationStack {
        BuildingsView()
    }
}
