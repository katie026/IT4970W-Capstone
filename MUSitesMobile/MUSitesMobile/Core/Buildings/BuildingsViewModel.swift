//
//  BuildingsViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/19/24.
//

import Foundation

@MainActor
final class BuildingsViewModel: ObservableObject {
    
    @Published private(set) var buildings: [Building] = []
    @Published private(set) var buildingTest: Building? = nil
    
    func getAllBuildings() async throws {
        self.buildings = try await BuildingsManager.shared.getAllBuildings()
    }
    
    func getBuilding(id: String) async throws {
        // Physics ID: vefZkRvjBxS1H1vSzR60
        // use authData to get user data from Firestore as Building struct
        self.buildingTest = try await BuildingsManager.shared.getBuilding(buildingId: id)
    }
}
