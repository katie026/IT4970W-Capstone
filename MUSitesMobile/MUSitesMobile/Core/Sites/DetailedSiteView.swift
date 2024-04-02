//
//  DetailedSiteView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/5/24.
//

import SwiftUI
import MapKit
import Foundation

struct DetailedSiteView: View {
    @StateObject private var viewModel = DetailedSiteViewModel()
    private var site: Site
    private var inventorySite: InventorySite
    
    init(site: Site, inventorySite: InventorySite) {
        self.site = site
        self.inventorySite = inventorySite
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.top)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Site Name
                        Text(site.name ?? "N/A")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        // Information and Inventory Sections
                        VStack(alignment: .leading, spacing: 0) {
                            // Information Section
                            SiteInfoView(building: viewModel.building, siteType: site.siteType)
                            //Equipment Section
                            SiteEquipmentView(site: site)
                            //Map Section
                            SiteMapView(site: site, building: viewModel.building)
                            // Inventory Section
                            NavigationLink(destination: DetailedInventorySiteView(inventorySiteId: inventorySite.id)) {
                                HStack {
                                    Spacer(minLength: 4) // Add a Spacer with a fixed width
                                    Text("Nearest Inventory")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical)
                            }
                            //Submit a Form section
                            NavigationLink(destination: SubmitView(siteName: site.name ?? "")) {
                                HStack {
                                    Spacer(minLength: 4)
                                    Text("Submit a Form")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical)
                            }
                            
                            //displaying the poster board views
                            Section(header: Text("Posters")) {
                                PostersView(imageURLs: viewModel.imageURLs)
                            }
                            Section(header: Text("Board")) {
                                BoardView(imageURLs: viewModel.boardImageURLs)
                            }
                        }
                        .padding(.horizontal)
                    }
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
        }
    }
}
struct DetailedSiteView_Previews: PreviewProvider {
    static var previews: some View {
        let site = Site(
            id: "siteId",
            name: "Sample Site",
            buildingId: "buildingId",
            nearestInventoryId: "inventoryId",
            chairCounts: [],
            siteType: "Sample Type",
            hasClock: true,
            hasInventory: true,
            hasWhiteboard: true,
            namePatternMac: "SAMPLE-MAC-##",
            namePatternPc: "SAMPLE-PC-##",
            namePatternPrinter: "Sample Printer ##"
        )
        
        let inventorySite = InventorySite(
            id: "inventoryId",
            name: "Sample Inventory Site",
            buildingId: "buildingId"
        )
        
        let building = Building(
            id: "buildingId",
            name: "Sample Building",
            siteGroup: "Sample Group"
        )
        
        let viewModel = DetailedSiteViewModel()
        viewModel.building = building
        
        return DetailedSiteView(site: site, inventorySite: inventorySite)
            .environmentObject(viewModel)
    }
}
