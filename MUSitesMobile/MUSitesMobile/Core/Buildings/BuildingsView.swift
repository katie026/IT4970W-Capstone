//
//  BuildingsView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/19/24.
//

import SwiftUI

struct BuildingsView: View {
    
    @StateObject private var viewModel = BuildingsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.buildings) { building in
                BuildingCellView(building: building)
            }
        }
        .navigationTitle("Buildings")
        .task {
            try? await viewModel.getAllBuildings()
        }
    }
}

#Preview {
    NavigationStack {
        BuildingsView()
    }
}
