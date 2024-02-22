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
            ForEach(viewModel.userBuildings, id: \.id.self) { userBuilding in
                BuildingCellViewBuilder(buildingId: userBuilding.buildingId)
                    .contextMenu {
                        // remove the UserBuilding
                        Button ("Remove from User Buildings") {
                            viewModel.removeUserBuilding(userBuildingId: userBuilding.id)
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
