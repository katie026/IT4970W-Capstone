//
//  DetailedSiteView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/5/24.
//
import SwiftUI
import MapKit

struct DetailedSiteView: View {
    @StateObject private var viewModel = DetailedSiteViewModel()
    
    private var site: Site
    @State private var informationSectionExpanded: Bool = true
    @State private var equipmentSectionExpanded: Bool = false
    @State private var pcSectionExpanded: Bool = false
    @State private var macSectionExpanded: Bool = false
    @State private var bwPrinterSectionExpanded: Bool = false
    @State private var colorPrinterSectionExpanded: Bool = false
    @State private var scannerSectionExpanded: Bool = false
    @State private var mapSectionExpanded: Bool = false
    @State private var postersSectionExpanded: Bool = true
    @State private var boardSectionExpanded: Bool = true
    
    init(site: Site) {
        self.site = site
    }
    
    var body: some View {
        VStack {
            Form {
                Section() {
                    DisclosureGroup(
                        isExpanded: $informationSectionExpanded,
                        content: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("**Group:** \(viewModel.building?.siteGroup ?? "N/A")")
                                Text("**Building:** \(viewModel.building?.name ?? "N/A")")
                                Text("**Site Type:** \(self.site.siteType ?? "N/A")")
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
                        isExpanded: $equipmentSectionExpanded,
                        content: {
                            
                            // PC section
                            Section() {
                                DisclosureGroup(
                                    isExpanded: $pcSectionExpanded,
                                    content: {
                                        Text(site.namePatternPc ?? "N/A")
                                    },
                                    label: {
                                        Text("**PC Count:** \(1)")
                                    }
                                )
                            }
                            // MAC section
                            Section() {
                                DisclosureGroup(
                                    isExpanded: $macSectionExpanded,
                                    content: {
                                        Text(site.namePatternMac ?? "N/A")
                                    },
                                    label: {
                                        Text("**MAC Count:** \(1)")
                                    }
                                )
                            }
                            // B&W Printer section
                            Section() {
                                DisclosureGroup(
                                    isExpanded: $bwPrinterSectionExpanded,
                                    content: {
                                        Text(site.namePatternMac ?? "N/A")
                                    },
                                    label: {
                                        Text("**B&W Printer Count:** \(1)")
                                    }
                                )
                            }
                            // Color Printer section
                            Section() {
                                DisclosureGroup(
                                    isExpanded: $colorPrinterSectionExpanded,
                                    content: {
                                        Text(site.namePatternMac ?? "N/A")
                                    },
                                    label: {
                                        Text("**Color Printer Count:** \(1)")
                                    }
                                )
                            }
                            
                            // Bools
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    if site.hasClock == true {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "xmark.square.fill")
                                            .foregroundColor(.red)
                                    }
                                    Text("Clock")
                                }
                                HStack {
                                    if site.hasInventory == true {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "xmark.square.fill")
                                            .foregroundColor(.red)
                                    }
                                    Text("Inventory")
                                }
                                HStack {
                                    if site.hasWhiteboard == true {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "xmark.square.fill")
                                            .foregroundColor(.red)
                                    }
                                    Text("Whiteboard")
                                }
                                
                            }
                        },
                        label: {
                            Text("Equipment")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    )
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                // Map
                Section() {
                    DisclosureGroup(
                        isExpanded: $mapSectionExpanded,
                        content: {
                            if let buildingCoordinates = viewModel.building?.coordinates {
                                SimpleMapView(
                                    coordinates: CLLocationCoordinate2D(
                                        latitude: buildingCoordinates.latitude,
                                        longitude: buildingCoordinates.longitude
                                    ),
                                    label: self.site.name ?? "N/A"
                                )
                                .listRowInsets(EdgeInsets())
                                .frame(height: 200)
                                .cornerRadius(8)
                            } else {
                                SimpleMapView(
                                    coordinates: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                                    label: self.site.name ?? "N/A"
                                )
                                .listRowInsets(EdgeInsets())
                                .frame(height: 200)
                                .cornerRadius(8)
                            }
                        },
                        label: {
                            Text("Map")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    )
                    .padding(.top, 10.0)
                    .listRowBackground(Color.clear)
                }
                //displaying the poster board views
                Section(header: Text("Posters")) {
                    PostersView(imageURLs: viewModel.imageURLs)
                }
                Section(header: Text("Board")) {
                    BoardView(imageURLs: viewModel.boardImageURLs)
                }
            }
        }
        .navigationTitle(site.name ?? "N/A")
        .onAppear {
            Task {
                await viewModel.loadBuilding(site: self.site)
                //this will take the current site the user is on(site.name) and then pass it to the fetchSiteSpecificImageURLs to get the specific images
                await viewModel.fetchSiteSpecificImageURLs(siteName: site.name ?? "Clark", category: "Posters")
                await viewModel.fetchSiteSpecificImageURLs(siteName: site.name ?? "Clark", category: "Board")
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailedSiteView(site: Site(id: "6tYFeMv41IXzfXkwbbh6", name: "Clark", buildingId: "SvK0cIKPNTGCReVCw7Ln", nearestInventoryId: "345", chairCounts: [ChairCount(count: 3, type: "physics_black")], siteType: "Other", hasClock: true, hasInventory: true, hasWhiteboard: false, namePatternMac: "CLARK-MAC-##", namePatternPc: "CLARK-PC-##", namePatternPrinter: "Clark Printer ##"))
    }
}
