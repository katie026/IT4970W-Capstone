//
//  UserBuildingsViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/21/24.
//

import Foundation

@MainActor
final class UserBuildingsViewModel: ObservableObject {
    
    @Published private(set) var userBuildings: [UserManager.UserBuilding] = []
    
    func getUserBuildings() {
        Task {
            // get current user
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            
            
            // get all current UserBuildings
            self.userBuildings = try await UserManager.shared.getAllUserBuildings(userId: authDataResult.uid)
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
