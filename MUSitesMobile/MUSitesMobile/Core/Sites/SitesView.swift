//
//  SitesView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/29/24.
//

import SwiftUI

struct SitesView: View {
    @StateObject private var viewModel = SitesViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.sites) { site in
                SiteCellView(site: site)
            }
//            if let site = viewModel.siteTest {
//                SiteCellView(site: site)
//            }
        }
        .navigationTitle("Sites")
        .onAppear {
            Task {
                try? await viewModel.getSites()
//                try? await viewModel.getSite(id: "6tYFeMv41IXzfXkwbbh6")
            }
        }
    }
}

#Preview {
    NavigationStack {
        SitesView()
    }
}
