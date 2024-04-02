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
                Section(header: Text("Admin")) {
                    //this is set up correctly(will show all users in the user collection
                    NavigationLink(destination: ViewUsersView()) {
                        Text("View Users")
                    }
                    //not set up yet
                    NavigationLink(destination: CreateUserView()) {
                        Text("Create User")
                    }
                    //listing all the sites(takes the user to a "new view" that shows all the sites)
                    NavigationLink(destination: SiteListView()) {
                        Text("Upload Images")
                    }
                }
                
                //not set up yet
                Section(header: Text("Inventory")) {
                    NavigationLink(destination: ViewInventorySitesView()) {
                        Text("View Inventory Sites")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Admin")
        }
    }
}

// Placeholder views for navigation destinations
struct CreateUserView: View {
    var body: some View { Text("Create User Content") }
}
struct ViewInventorySitesView: View {
    var body: some View { Text("View Inventory Sites Content") }
}
// ... Add the rest of the destination views similarly

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
    }
}





