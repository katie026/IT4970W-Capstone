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
    @State private var selection = 5
    
    var body: some View {
        TabView(selection:$selection) {
            // Map View
            NavigationStack {
                SitesMapView()
            }
            .tabItem {
                Image(systemName: "map")
                Text("Map")
            }.tag(1)
            
            // Buildings View
            NavigationStack {
                BuildingsView()
            }
            .tabItem {
                Image(systemName: "building.2")
                Text("Buildings")
            }.tag(2)
            
            // Sites View
            NavigationStack {
                SitesView()
            }
            .tabItem {
                Image(systemName: "building.fill")
                Text("Sites")
            }.tag(3)
            
            // Productivity View
            NavigationStack {
                UserProductivityView()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Tasks")
            }.tag(4)
            
            // Profile View
            NavigationStack {
                ProfileView(showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text(isAdmin ? "Admin" : "Profile")
            }.tag(5)
        }
    }
}

#Preview {
    TabBarView(showSignInView: .constant(false))
}
