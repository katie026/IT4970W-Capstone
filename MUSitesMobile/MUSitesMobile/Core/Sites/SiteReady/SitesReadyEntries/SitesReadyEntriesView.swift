//
//  SitesReadyEntriesView.swift
//  MUSitesMobile
//
//  Created by Tristan Winship on 4/21/24.
//

import SwiftUI
import FirebaseFirestore

struct SiteReadyEntriesView: View {
    @StateObject var viewModel = SitesReadyEntriesViewModel()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a 'UTC'Z"
        return formatter
    }()

    var body: some View {
        NavigationView {
            VStack {
                DateRangePicker(startDate: $viewModel.startDate, endDate: $viewModel.endDate) {
                    viewModel.fetchSitesReadyEntries()
                }
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
                            Text("Timestamp: \(dateFormatter.string(from: timestamp))")
                        } else {
                            Text("Timestamp: N/A")
                        }
                        // Add more Text views for other properties
                    }
                    .padding(.vertical, 8)
                }
                .navigationTitle("Site Ready Entries")
            }
        }
        .onAppear {
            viewModel.fetchSitesReadyEntries()
        }
    }
}

struct SiteReadyEntriesView_Previews: PreviewProvider {
    static var previews: some View {
        SiteReadyEntriesView()
    }
}

struct DateRangePicker: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    let action: () -> Void

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Date Range:")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
                Button("Apply", action: action)
            }
            .padding([.horizontal, .top])
            
            HStack {
                DatePicker(
                    "Start Date:",
                    selection: $startDate,
                    in: ...endDate,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .padding([.horizontal, .bottom])
                
                Text("to")
                    .padding([.horizontal, .bottom])
                
                DatePicker(
                    "End Date:",
                    selection: $endDate,
                    in: startDate...Date(),
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .padding([.horizontal, .bottom])
            }
        }
        .padding()
    }
}
