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
//        .onAppear {
//            if !didAppear {
//                viewModel.addListenerForUserBuildings()
//                didAppear = true
//            }
        .onFirstAppear {
            viewModel.addListenerForUserBuildings()
        }
    }
}

#Preview {
    NavigationStack{
        UserBuildingsView()
    }
}

// Custom View Modifier
struct OnFirstAppearViewModifier: ViewModifier {
    
    @State private var didAppear: Bool = false
    let perform: (() -> Void)? // takes a function that returns Void and is optional
    
    func body(content: Content) -> some View {
        // view's original content
        content
        // modify view to perform action once
        .onAppear {
            // check if action has already been performed
            if !didAppear {
                // do something once
                perform?()
                // update that action has been perfromed once
                didAppear = true
            }
        }
    }
}

extension View {
    // add modifier and return the updated view iwth the modfier attached
    func onFirstAppear(perform: (() -> Void)?) -> some View {
        modifier(OnFirstAppearViewModifier(perform: perform))
    }
}
