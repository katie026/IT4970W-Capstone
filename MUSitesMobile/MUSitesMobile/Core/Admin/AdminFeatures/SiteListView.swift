//
//  SiteListView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 3/29/24.
//

import Foundation
import SwiftUI

//this is purely for the admin view, I wanted to get the list of sites from the siteManager file but this just worked better 
struct SiteListView: View {
    @State private var sites: [Site] = []
    @State private var isLoading = true
    @State private var error: Error?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
            } else {
                listSites()
            }
        }
        .navigationTitle("Select a Site")
        .onAppear {
            Task {
                await fetchSites()
            }
        }
    }

    @ViewBuilder
    private func listSites() -> some View {
        List(sites) { site in  // 'sites' must conform to Identifiable
            NavigationLink(destination: CategoryPickerView(selectedSiteName: site.name ?? "Default")) {
                Text(site.name ?? "Default")
            }
        }
    }

    private func fetchSites() async {
        do {
            let fetchedSites = try await SitesManager.shared.getAllSites(descending: true)  // Adjust based on your needs
            sites = fetchedSites
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
}
