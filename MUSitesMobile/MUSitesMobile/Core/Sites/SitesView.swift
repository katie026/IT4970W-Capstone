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
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search", text: $searchText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                List {
                    ForEach(sortedSites) { site in
                        SiteCellView(site: site)
                    }
                }
            }
            .navigationTitle("Sites")
            .onAppear {
                viewModel.getSites() // Refresh sites when the view appears
            }
        }
    }
    
    private var sortedSites: [Site] {
        if searchText.isEmpty {
            return viewModel.sites.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
        } else {
            return viewModel.sites.filter {
                $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
        }
    }
}

struct SitesView_Previews: PreviewProvider {
    static var previews: some View {
        SitesView()
    }
}

