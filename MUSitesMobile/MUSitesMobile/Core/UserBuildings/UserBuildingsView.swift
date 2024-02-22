//
//  UserBuildingsView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/21/24.
//

import SwiftUI

struct UserBuildingsView: View {
    
    @StateObject private var viewModel = UserBuildingsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.buildings, id: \.userBuilding.id.self) { item in
                BuildingCellView(building: item.building)
                    .contextMenu {
                        // remove the UserBuilding
                        Button ("Remove from User Buildings") {
                            viewModel.removeUserBuilding(userBuildingId: item.userBuilding.id)
                        }
                    }
            }
        }
        .navigationTitle("User Tasks")
        .onAppear {
            viewModel.getUserBuildings()
        }
    }
}

#Preview {
    NavigationStack{
        UserBuildingsView()
    }
}
