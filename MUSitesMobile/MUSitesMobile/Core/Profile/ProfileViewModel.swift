//
//  ProfileViewModel.swift
//  MUSitesMobile
//
//  Created by J Kim on 2/19/24.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    // ObservableObject means any changes to ProfileViewModel will trigger re-rendering of associated views
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        // get authData for current user
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        // use authData to get user data from Firestore as DBUser struct
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func toggleClockInStatus() {
        // check if current user exists
        guard let user else { return }
        // get currentValue of isClockedIn, if nil return currentValue as false
        let currentValue = user.isClockedIn ?? false
        Task {
            // swap currentValue and send updated user info to Firestore
            try await UserManager.shared.updateUserClockInStatus(userId: user.userId, isClockedIn: !currentValue)
            // get updated user info from Firestore
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addUserPosition(text: String) {
        guard let user else {return}
        
        Task {
            // add position to user in Firestore
            try await UserManager.shared.addUserPosition(userId: user.userId, position: text)
            // get updated user info from Firestore
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeUserPosition(text: String) {
        guard let user else {return}
        
        Task {
            // remove position to user in Firestore
            try await UserManager.shared.removeUserPosition(userId: user.userId, position: text)
            // get updated user info from Firestore
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addChairReport() {//chairType: String, chairCount: Int) {
        guard let user else {return}
        let chairReport = ChairReport(chairType: "001", chairCount: 20)
        
        Task {
            // add chair report to user in Firestore
            try await UserManager.shared.addChairReport(userId: user.userId, chairReport: chairReport)
            // get updated user info from Firestore
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeChairReport() {
        guard let user else {return}
        
        Task {
            // remove chair report to user in Firestore
            try await UserManager.shared.removeChairReport(userId: user.userId)
            // get updated user info from Firestore
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}