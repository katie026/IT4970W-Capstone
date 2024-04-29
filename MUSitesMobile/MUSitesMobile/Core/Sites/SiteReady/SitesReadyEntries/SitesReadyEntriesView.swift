//
//  SitesReadyEntriesView.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 4/21/24.
//

import SwiftUI

struct SiteReadyEntriesView: View {
    @StateObject var viewModel = SitesReadyEntriesViewModel()
    
    var body: some View {
        List(viewModel.entries) { entry in
            VStack(alignment: .leading, spacing: 8) {
                Text("ID: \(entry.id)")
                Text("BW Printer Count: \(entry.bwPrinterCount ?? 0)")
                Text("Chair Count: \(entry.chairCount ?? 0)")
                Text("Color Printer Count: \(entry.colorPrinterCount ?? 0)")
                Text("MAC Count: \(entry.macCount ?? 0)")
                Text("Missing Chairs: \(entry.missingChairs ?? 0)")
                Text("PC Count: \(entry.pcCount ?? 0)")
                Text("Comments: \(entry.comments ?? "")")
                Text("Computing Site: \(entry.computingSite ?? "")")
                Text("Issues: \(entry.issues?.joined(separator: ", ") ?? "")")
                Text("Scanner Count: \(entry.scannerCount ?? 0)")
                Text("User: \(entry.user ?? "")")
                if let timestamp = entry.timestamp {
                    Text("Timestamp: \(timestamp)")
                } else {
                    Text("Timestamp: N/A")
                }
                // Add more Text views for other properties
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Site Ready Entries")
        .onAppear {
            viewModel.fetchSitesReadyEntries()
        }
    }
}

#Preview {
    NavigationView {
        SiteReadyEntriesView()
    }
}
