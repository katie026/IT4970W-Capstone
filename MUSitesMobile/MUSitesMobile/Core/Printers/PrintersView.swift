//
//  PrintersView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 5/2/24.
//

import SwiftUI

@MainActor
final class PrintersViewModel: ObservableObject {
    @Published var printers: [Printer] = []
    @Published var selectedSite: Site = Site(id: "", name: "any site", buildingId: "", nearestInventoryId: "", chairCounts: [ChairCount(count: 0, type: "")], siteTypeId: "", hasClock: false, hasInventory: false, hasWhiteboard: false, hasPosterBoard: false, namePatternMac: "", namePatternPc: "", namePatternPrinter: "", calendarName: "")
    @Published var sites: [Site] = []
    @Published var selectedSort: PrinterSortOption? = nil
    
    enum PrinterSortOption: String, CaseIterable {
        // CaseIterable so we can loop through them
        case name
        case section
        
        var optionString: String {
            switch self {
            case .name: return "Name"
            case .section: return "Section"
            }
        }
    }
    
    func getPrinters(siteId: String?, completion: @escaping () -> Void) {
        Task {
            if let siteId {
                do {
                    self.printers = try await PrinterManager.shared.getAllPrinters(descending: false, siteId: siteId)
                } catch {
                    print("Error fetching printers: \(error)")
                }
                completion()
            } else {
                self.printers = try await PrinterManager.shared.getAllPrinters(descending: false, siteId: nil)
                completion()
            }
        }
    }
    
    func getSites(completion: @escaping () -> Void) {
        Task {
            self.sites = try await SitesManager.shared.getAllSites(descending: false)
            completion()
        }
    }
    
    func swapPrintersOrder() {
        printers.reverse()
    }
    
    func sortPrintersByName() {
        printers = printers.sorted { $0.name ?? "" < $1.name ?? ""}
    }
    
    func sortPrintersBySection() {
        printers = printers.sorted { $0.section ?? "" < $1.section ?? ""}
    }
}

struct PrintersView: View {
    // View Model
    @StateObject private var viewModel = PrintersViewModel()
    // View Control
    @State private var hasLoadedOnce = false
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                // Header
                HStack(alignment: .center) {
                    Text("Computing Site:").fontWeight(.bold)
                    sitePicker
                    Spacer()
                    sortButton
                    refreshButton
                }.padding([.horizontal, .top])
                
                // Printer List
                printerList
            }
        }
        .navigationTitle("Printers")
        .onAppear {
            // get list of sites
            viewModel.getSites() {
                isLoading = false
            }
        }
        .toolbar(content: {
            // Sorting
            ToolbarItem(placement: .navigationBarTrailing) {
                // will be sorted by name by default
                Menu("Sort by: \(viewModel.selectedSort?.optionString ?? "Name")") {
                    ForEach(PrintersViewModel.PrinterSortOption.allCases, id: \.self) { option in
                        Button(option.optionString) {
                            switch option {
                            case .name:
                                viewModel.selectedSort = .name
                                viewModel.sortPrintersByName()
                            case .section:
                                viewModel.selectedSort = .section
                                viewModel.sortPrintersBySection()
                            }
                        }
                    }
                }
            }
        })
    }
    
    private var printerList: some View {
        List {
            // if computers have not been laoded yet
            if !hasLoadedOnce {
                // prompt user
                Text("Select a site, and reload.")
                    .foregroundColor(.gray)
                // else, if site has been selected, and the computer count is still 0
            } else if (hasLoadedOnce && viewModel.printers.count == 0) {
                // tell user there are no computers
                Text("There are no printers at \(viewModel.selectedSite.name ?? "this site").")
                    .foregroundColor(.gray)
            } else {
                // loop through computers
                ForEach(viewModel.printers) { printer in
                    printerRow(printer: printer)
                }
            }
        }
    }
    
    private func printerRow(printer: Printer) -> some View {
        let result = VStack(alignment: .leading) {
            // PRINTER NAME
            Text(printer.name ?? "N/A")
            
            // TYPE
            if let type = printer.type {
                Text("\(type)")
                    .font(.system(size: 12))
            }
        }.padding(.vertical, 1)
        
        return AnyView(result)
    }
    
    private var sitePicker: some View {
        // Site Picker
        Picker("Computing Site:", selection: $viewModel.selectedSite) {
            // Option for All sites
            Text("All").tag(Site(id: "", name: "All", buildingId: "", nearestInventoryId: "", chairCounts: [ChairCount(count: 0, type: "")], siteTypeId: "", hasClock: false, hasInventory: false, hasWhiteboard: false, hasPosterBoard: false, namePatternMac: "", namePatternPc: "", namePatternPrinter: "", calendarName: ""))
            
            // Options for each site in Site list
            ForEach(viewModel.sites) { site in
                // dispay the name
                Text(site.name ?? "N/A").tag(site) // tag associates each Site with itself
            }
        }
    }
    
    private var refreshButton: some View {
        Button(action: {
            isLoading = true
            fetchPrinters()
            hasLoadedOnce = true
            viewModel.selectedSort = .name
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20))
        }
    }
    
    private var sortButton: some View {
        Button(action: {
            viewModel.swapPrintersOrder()
        }) {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 20))
                .padding(.trailing, 10)
        }
    }
    
    func fetchPrinters() {
        Task {
            if viewModel.selectedSite.id != "" {
                viewModel.getPrinters(siteId: viewModel.selectedSite.id) {
                    print("Got \(viewModel.printers.count) printers.")
                    isLoading = false
                }
            } else {
                viewModel.getPrinters(siteId: nil) {
                    print("Got \(viewModel.printers.count) printers.")
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        PrintersView()
    }
}
