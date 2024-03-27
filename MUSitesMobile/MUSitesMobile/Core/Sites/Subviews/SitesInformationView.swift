//
//  SitesInformationView.swift
//  MUSitesMobile
//
//  Created by Michael Oreto on 3/26/24.
//
import Foundation
import SwiftUI

struct siteInformationView: View {
    @StateObject private var viewModel = DetailedSiteViewModel()
    var site: Site

    var body: some View {
        Section {
            DisclosureGroup(
                isExpanded: .constant(true),
                content: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("**Group:** \(viewModel.building?.siteGroup ?? "N/A")")
                        Text("**Building:** \(viewModel.building?.name ?? "N/A")")
                        Text("**Site Type:** \(site.siteType ?? "N/A")")
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
    }
}
