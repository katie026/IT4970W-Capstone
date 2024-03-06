//
//  DetailedSiteView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/5/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class DetailedSiteViewModel: ObservableObject {
    @Published var site: Site?
    @Published var building: Building?
    
    func loadSite(siteId: String) async {
        do {
            self.site = try await SitesManager.shared.getSite(siteId: siteId)
            // Load the associated building
            if let buildingId = self.site?.buildingId {
                try await loadBuilding(buildingId: buildingId)
            }
        } catch {
            print("Error loading site: \(error.localizedDescription)")
            // Handle the error, e.g., show an alert or update the UI accordingly
        }
    }

    func loadBuilding(buildingId: String) async {
        do {
            self.building = try await BuildingsManager.shared.getBuilding(buildingId: buildingId)
        } catch {
            print("Error loading building: \(error.localizedDescription)")
            // Handle the error, e.g., show an alert or update the UI accordingly
        }
    }
}


struct DetailedSiteView: View {
    @StateObject private var viewModel = DetailedSiteViewModel()
    
    private var site: Site
    @State private var section1Expanded: Bool = true
    @State private var section2Expanded: Bool = false

    init(site: Site) {
        self.site = site
    }

    var body: some View {
        VStack {
            Form {
                Section() {
                    DisclosureGroup(
                        isExpanded: $section1Expanded,
                        content: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("**Group:** \(viewModel.building?.siteGroup ?? "N/A")")
                                Text("**Building:** \(viewModel.building?.name ?? "N/A")")
                                Text("**Site Type:** \(viewModel.building?.siteGroup ?? "N/A")")
                                Text("**SS Captain:** \(viewModel.building?.siteGroup ?? "N/A")")
                            }
                            .listRowInsets(EdgeInsets())
                        },
                        label: {
                            Text("Information")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    )
                    .padding(.top, 10.0)
                    .listRowBackground(Color.clear)
                }
                
                Section() {
                    DisclosureGroup(
                        isExpanded: $section2Expanded,
                        content: {
                            Text("Section 2 Content goes here")
                        },
                        label: {
                            Text("Equipment")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    )
                }
            }
        }
        .navigationTitle(site.name ?? "N/A")
        .onAppear {
            Task {
                await viewModel.loadSite(siteId: site.id)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailedSiteView(site: Site(id: "6tYFeMv41IXzfXkwbbh6", name: "Clark", buildingId: "SvK0cIKPNTGCReVCw7Ln", nearestInventoryId: "345", chairCounts: [ChairCount(count: 3, type: "physics_black")], hasClock: true, hasInventory: true, hasWhiteboard: true, namePatternMac: "CLARK-MAC-##", namePatternPc: "CLARK-PC-##", namePatternPrinter: "Clark Printer ##"))
    }
}
