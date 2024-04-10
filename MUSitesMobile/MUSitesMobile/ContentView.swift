//
//  ContentView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/13/24.
//

import SwiftUI

@MainActor
final class ContentViewModel: ObservableObject {
    var siteGroups: [SiteGroup] = []
    func getSiteGroups() {
        Task {
            do {
                self.siteGroups = try await SiteGroupManager.shared.getAllSiteGroups(descending: nil)
            } catch {
                print("Error getting site groups: \(error)")
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            List {
                ForEach(viewModel.siteGroups) { group in
                    Text(group.name)
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.getSiteGroups()
        }
    }
}

#Preview {
    ContentView()
}
