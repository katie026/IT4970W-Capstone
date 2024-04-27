//
//  TabBarView.swift
//  MUSitesMobile
//
//  Created by J Kim on 2/21/24.
//

import SwiftUI

struct TabBarView: View {
    
    @Binding var showSignInView: Bool
    @State private var isAdmin = false
    
    var body: some View {
        TabView {
            // Map View
            NavigationStack {
                SitesMapView()
            }
            .tabItem {
                Image(systemName: "map")
                Text("Map")
            }
            
            // Buildings View
            NavigationStack {
                BuildingsView()
            }
            .tabItem {
                Image(systemName: "building.2")
                Text("Buildings")
            }
            
            // Sites View
            NavigationStack {
                SitesView()
            }
            .tabItem {
                Image(systemName: "building.fill")
                Text("Sites")
            }
            
            // Inventory Sites View
            NavigationStack {
                InventorySitesView()
            }
            .tabItem {
                Image(systemName: "cabinet.fill")
                Text("Inventory")
            }
            
            // Profile View
            NavigationStack {
                ProfileView(showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text(isAdmin ? "Admin" : "Profile")
            }
        }
    }
}

#Preview {
    TabBarView(showSignInView: .constant(false))
}
