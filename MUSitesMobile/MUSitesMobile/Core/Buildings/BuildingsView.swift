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
        let selectedGroupId = viewModel.selectedGroup?.id
        
        if searchText.isEmpty {
            if selectedGroupId != nil {
                return viewModel.buildings
                    .filter { $0.siteGroupId ?? "" == selectedGroupId }
            } else {
                return viewModel.buildings // no filter
            }
        } else {
            if selectedGroupId != nil {
                return viewModel.buildings
                    .filter { $0.siteGroupId ?? "" == selectedGroupId }
                    .filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
                    .sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
            } else {
                return viewModel.buildings
                    .filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
                    .sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 5) {
                searchBar
                    .frame(width: .infinity)
                Spacer()
                sortButton
            }
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
            // Filtering
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Site Group: \(viewModel.selectedGroup?.name ?? "All")") {
                    Picker("Site Group", selection: $viewModel.selectedGroup) {
                        Text("All").tag(nil as SiteGroup?)
                        ForEach(viewModel.allSiteGroups, id: \.self) { group in
                            Text(group.name).tag(group as SiteGroup?)
                        }
                    }.multilineTextAlignment(.leading)
                }
            }
        })
        .onAppear {
            Task {
                viewModel.getBuildings()
                viewModel.getSiteGroups(){}
            }
        }
    }
    
    private var searchBar: some View {
        TextField("Search", text: $searchText)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
    }
    
    private var sortButton: some View {
        Button(action: {
            viewModel.swapBuildingsOrder()
        }) {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 20))
        }
    }
}

#Preview {
    NavigationStack {
        BuildingsView()
    }
}
