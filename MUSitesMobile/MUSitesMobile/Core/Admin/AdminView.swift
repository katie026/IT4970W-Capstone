//
//  AdminView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 3/26/24.
//

import SwiftUI

struct AdminView: View {
    var body: some View {
        List {
            // USER SECTION
            Section("Users") {
                //this is set up correctly(will show all users in the user collection
                NavigationLink(destination: ViewUsersView()) {
                    Label{Text("View Users")} icon: {Image(systemName: "person.3.fill")
                        .foregroundColor(.accentColor)}
                }
            }
            
            // INVENTORY SECTION
            Section("Location Lists") {
                NavigationLink(destination: BuildingsView()) {
                    Label{Text("View Buildings")} icon: {Image(systemName: "building.2.fill")
                        .foregroundColor(.blue)}
                }
                NavigationLink(destination: SitesView()) {
                    Label{Text("View Computing Sites")} icon: {Image(systemName: "door.right.hand.closed")
                        .foregroundColor(.blue)}
                }
                NavigationLink(destination: InventorySitesView()) {
                    Label{Text("View Inventory Sites")} icon: {Image(systemName: "cabinet.fill")
                        .foregroundColor(.blue)}
                }
            }
            
            Section("Images") {
                NavigationLink(destination: SiteListView()) { // we should rename this
                    Label{Text("Images")} icon: {Image(systemName: "photo.fill")
                        .foregroundColor(.purple)}
                }
            }
            Section(header: Text("Submission Data")) {
                NavigationLink(destination: InventoryEntriesView()) {
                    Label{Text("Inventory Entries")} icon: {Image(systemName: "cabinet.fill")
                        .foregroundColor(.green)}
                }
                NavigationLink(destination: HourlyCleaningsView()) {
                    Label{Text("Hourly Cleanings")} icon: {Image(systemName: "bubbles.and.sparkles.fill")
                        .foregroundColor(.green)}
                }
                NavigationLink(destination: SiteCaptainsView()) {
                    Label{Text("Site Captain Entries")} icon: {Image(systemName: "laptopcomputer.and.ipad")
                        .foregroundColor(.green)}
                }
                NavigationLink(destination: SiteReadyEntriesView()) {
                    Label{Text("Site Ready Entries")} icon: {Image(systemName: "studentdesk")
                        .foregroundColor(.green)}
                }
                NavigationLink(destination: IssuesView()) {
                    Label{Text("Issues")} icon: {Image(systemName: "wrench.and.screwdriver.fill")
                        .foregroundColor(.red)}
                }
                NavigationLink(destination: SupplyRequestsView()) {
                    Label{Text("Supply Requests")} icon: {Image(systemName: "shippingbox.fill")
                        .foregroundColor(.red)}
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Admin")
    }
}



#Preview {
    NavigationView {
        AdminView()
    }
}
