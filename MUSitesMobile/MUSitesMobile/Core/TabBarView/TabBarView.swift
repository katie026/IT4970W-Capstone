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
        }
    }
}

#Preview {
    TabBarView(showSignInView: .constant(false))
}
