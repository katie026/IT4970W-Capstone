//
//  UserBuildingsViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/21/24.
//

import Foundation

@MainActor
final class UserBuildingsViewModel: ObservableObject {
    
    @Published private(set) var buildings: [(userBuilding: UserManager.UserBuilding, building: Building)] = []
    
    func getUserBuildings() {
        Task {
            // get current user
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            
            
            // get all current UserBuildings
            let userBuildings = try await UserManager.shared.getAllUserBuildings(userId: authDataResult.uid)
            
            // create empty array to return
            var localArray: [(userBuilding: UserManager.UserBuilding, building: Building)] = []
            
            // for every UserBuilding
            for userBuilding in userBuildings {
                // get the Building that the UserBuilding is and return as a tuple
                if let building = try? await BuildingsManager.shared.getBuilding(buildingId: userBuilding.buildingId) {
                    localArray.append((userBuilding, building))
                }
            }
            self.buildings = localArray
        }
    }
    
    func removeUserBuilding(userBuildingId: String) {
        // remove UserBuilding from Firestore
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try?await UserManager.shared.removeUserBuilding(userId: authDataResult.uid, userBuildingId: userBuildingId)
        }
        // reload list
        getUserBuildings()
    }
}
