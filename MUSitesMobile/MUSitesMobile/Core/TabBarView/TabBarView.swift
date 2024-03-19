//
//  TabBarView.swift
//  MUSitesMobile
//
//  Created by J Kim on 2/21/24.
//

import SwiftUI

struct TabBarView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        TabView {
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
            NavigationStack {
                SitesMapView()
            }
            .tabItem {
                Image(systemName: "map")
                Text("Sites Map")
            }
            
            // Inventory Sites View
            NavigationStack {
                InventorySitesView()
            }
            .tabItem {
                Image(systemName: "cabinet.fill")
                Text("Inventory")
            }
            
            // UserTasks View
            NavigationStack {
                UserBuildingsView()
            }
            .tabItem {
                Image(systemName: "checklist")
                Text("Tasks")
            }
            
            // Profile View
            NavigationStack {
                ProfileView(showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }
            
            // NonAuthUser View
            NavigationStack {
                NonAuthUsersView()
            }
            .tabItem {
                Image(systemName: "person.circle")
                Text("Non-Auth Users")
            }
        }
    }
}

#Preview {
    TabBarView(showSignInView: .constant(false))
}
