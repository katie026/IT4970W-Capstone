//
//  DetailedSiteView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/5/24.
//

import SwiftUI

struct DetailedSiteView: View {
    @StateObject private var viewModel = DetailedSiteViewModel()
    private var site: Site
    let inventorySite: InventorySite
    @State private var section1Expanded: Bool = true
    @State private var section2Expanded: Bool = false
    
    init(site: Site, inventorySite: InventorySite) {
        self.site = site
        self.inventorySite = inventorySite
    }

    var body: some View {
        VStack {
            Form {
                Section {
                    DisclosureGroup(isExpanded: $section1Expanded) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("**Group:** \(viewModel.building?.siteGroup ?? "N/A")")
                            Text("**Building:** \(viewModel.building?.name ?? "N/A")")
                            Text("**Site Type:** \(viewModel.building?.siteGroup ?? "N/A")")
                            Text("**SS Captain:** \(viewModel.building?.siteGroup ?? "N/A")")
                        }
                        .listRowInsets(EdgeInsets())
                    } label: {
                        Text("Information")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 10.0)
                    .listRowBackground(Color.clear)
                }
                
                Section {
                    DisclosureGroup(isExpanded: $section2Expanded) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("**Has Clock:** \(site.hasClock == true ? "Yes" : "No")")
                            Text("**Has Inventory:** \(site.hasInventory == true ? "Yes" : "No")")
                            Text("**Has Whiteboard:** \(site.hasWhiteboard == true ? "Yes" : "No")")
                            Text("**Name Pattern (Mac):** \(site.namePatternMac ?? "N/A")")
                            Text("**Name Pattern (PC):** \(site.namePatternPc ?? "N/A")")
                            Text("**Name Pattern (Printer):** \(site.namePatternPrinter ?? "N/A")")
                        }
                        .listRowInsets(EdgeInsets())
                    } label: {
                        Text("Equipment")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 10.0)
                    .listRowBackground(Color.clear)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        NavigationLink(destination: SitesMap()) {
                            HStack {
                                Image(systemName: "map")
                                    .foregroundColor(.blue)
                                Text("Map")
                                    .font(.headline)
                                Spacer()
                            }
                        }
                    }
                }
                
                Section {
                    NavigationLink(destination: DetailedInventorySiteView(inventorySite: inventorySite)) {
                        Image(systemName: "cabinet")
                            .foregroundColor(.blue)
                        Text("Nearest Inventory")
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        NavigationLink(destination: SubmitView()) {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.blue)
                                Text("Submit")
                                    .font(.headline)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .font(.callout)
        .foregroundStyle(.secondary)
        .navigationTitle(site.name ?? "N/A")
        .onAppear {
            Task {
                await viewModel.loadSite(siteId: site.id)
            }
        }
    }
}
