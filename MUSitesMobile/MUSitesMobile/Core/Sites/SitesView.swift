//
//  SitesView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/29/24.
//

import SwiftUI

struct SitesView: View {
    @StateObject private var viewModel = SitesViewModel()
    @State private var searchText = ""
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 5) {
                searchBar
                    .frame(width: .infinity)
                Spacer()
                sortButton
            }
            .padding()
            
            if isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(sortedSites) { site in
                        SiteCellView(site: site)
                    }
                }
            }
        }
        .navigationTitle("Sites")
        .onAppear {
            viewModel.getSites{
                isLoading = false
            }
            viewModel.getBuildings(){}
            viewModel.getSiteGroups(){}
        }
        .toolbar(content: {
            // Filtering
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Site Group: \(viewModel.selectedGroup?.name ?? "All")") {
                    Picker("Site Group", selection: $viewModel.selectedGroup) {
                        Text("All").tag(nil as SiteGroup?)
                        ForEach(viewModel.siteGroups, id: \.self) { group in
                            Text(group.name).tag(group as SiteGroup?)
                        }
                    }.multilineTextAlignment(.leading)
                }
            }
        })
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
            viewModel.swapSitesOrder()
        }) {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 20))
        }
    }
    
//    private var sortedSites: [Site] {
//        if searchText.isEmpty {
//            return viewModel.sites.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
//        } else {
//            return viewModel.sites.filter {
//                $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
//            }.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
//        }
//    }
    
    private var sortedSites: [Site] {
        let selectedGroupId = viewModel.selectedGroup?.id
        
        if searchText.isEmpty {
            if selectedGroupId != nil {
                return viewModel.sites
                    .filter { site in
                        let building = viewModel.buildings.first(where: { $0.id == site.buildingId })
                        if building != nil {
                            return building?.siteGroupId == selectedGroupId
                        } else {
                            return false
                        }
                    }
            } else {
                return viewModel.sites // no filter
            }
        } else {
            if selectedGroupId != nil {
                return viewModel.sites
                    .filter { site in
                        let building = viewModel.buildings.first(where: { $0.id == site.buildingId })
                        if building != nil {
                            return building?.siteGroupId == selectedGroupId
                        } else {
                            return false
                        }
                    }
                    .filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
                    .sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
            } else {
                return viewModel.sites
                    .filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
                    .sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
            }
        }
    }
}

#Preview {
    NavigationView {
        SitesView()
    }
}
