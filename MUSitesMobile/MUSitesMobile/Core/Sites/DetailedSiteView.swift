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
  @State private var section1Expanded: Bool = true
  @State private var section2Expanded: Bool = false

  init(site: Site) {
    self.site = site
  }

  var body: some View {
    VStack {
      Form {
        Section(header: Text("Information").font(.title).fontWeight(.bold)) {
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

        Section(header: Text("Equipment").font(.title).fontWeight(.bold)) {
          DisclosureGroup(
            isExpanded: $section2Expanded,
            content: {
              VStack(alignment: .leading, spacing: 8) {
                Text("**Has Clock:** \(site.hasClock == true ? "Yes" : "No")")
                Text("**Has Inventory:** \(site.hasInventory == true ? "Yes" : "No")")
                Text("**Has Whiteboard:** \(site.hasWhiteboard == true ? "Yes" : "No")")
                Text("**Name Pattern (Mac):** \(site.namePatternMac ?? "N/A")")
                Text("**Name Pattern (PC):** \(site.namePatternPc ?? "N/A")")
                Text("**Name Pattern (Printer):** \(site.namePatternPrinter ?? "N/A")")
              }
            },
            label: {
              Text("Equipment")
                .font(.headline)
            }
          )
          .padding(.vertical, 8)
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

// Preview (unmodified)
#Preview {
  NavigationStack {
    DetailedSiteView(site: Site(id: "6tYFeMv41IXzfXkwbbh6", name: "Clark", buildingId: "SvK0cIKPNTGCReVCw7Ln", nearestInventoryId: "345", chairCounts: [ChairCount(count: 3, type: "physics_black")], hasClock: true, hasInventory: true, hasWhiteboard: true, namePatternMac: "CLARK-MAC-##", namePatternPc: "CLARK-PC-##", namePatternPrinter: "Clark Printer ##"))
  }
}
