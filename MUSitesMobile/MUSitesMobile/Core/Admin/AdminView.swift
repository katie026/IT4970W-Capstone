//
//  AdminView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 3/26/24.
//

import SwiftUI

struct AdminView: View {
    var body: some View {
        NavigationView {
            List {
                // USER SECTION
                Section("Users") {
                    //this is set up correctly(will show all users in the user collection
                    NavigationLink(destination: ViewUsersView()) {
                        Text("View Users")
                    }
                }
                
                // INVENTORY SECTION
                Section("Inventory") {
                    NavigationLink(destination: InventorySitesView()) {
                        Text("View Inventory Sites")
                    }
                    NavigationLink(destination: InventoryEntriesView()) {
                        Text("View Inventory Entries")
                    }
                }
                
                Section("Images") {
                    NavigationLink(destination: SiteListView()) { // we should rename this
                        Text("Upload Images")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Admin")
        }
    }
}



#Preview {
    AdminView()
}
