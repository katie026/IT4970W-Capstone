//
//  UserBuildingsViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/21/24.
//

import Foundation
import Combine

@MainActor
final class UserBuildingsViewModel: ObservableObject {
    
    @Published private(set) var userBuildings: [UserBuilding] = []
    private var cancellables = Set<AnyCancellable>()
    
    func addListenerForUserBuildings() {
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        
        UserManager.shared.addListenerForAllUserBuildings(userId: authDataResult.uid)
            // combine completions
            .sink { completion in
                
            } receiveValue: { [weak self] buildings in
                self?.userBuildings = buildings
            }
            .store(in: &cancellables)
        
//        UserManager.shared.addLaistenerForAllUserBuildings(userId: authDataResult.uid) { [weak self] buildings in
//            // hard reference to self disallows this class from being de-allocate because the function is alive and we are waiting for the result to come back
//            // weak references tells compiler to not do anything if self is nil when this returns
//            self?.userBuildings = buildings
//        }
    }
    
//    func getUserBuildings() {
//        Task {
//            // get current user
//            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//            
//            
//            // get all current UserBuildings
//            self.userBuildings = try await UserManager.shared.getAllUserBuildings(userId: authDataResult.uid)
//        }
//    }
    
    func removeUserBuilding(userBuildingId: String) {
        // remove UserBuilding from Firestore
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try?await UserManager.shared.removeUserBuilding(userId: authDataResult.uid, userBuildingId: userBuildingId)
        }
//        // reload list
//        getUserBuildings()
    }
}
