//
//  ProfileViewModel.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/19/24.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    // ObservableObject means any changes to ProfileViewModel will trigger re-rendering of associated views
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var keySet: KeySet? = nil
    @Published private(set) var keys: [Key]? = nil
    @Published private(set) var keyTypeCodeMap: [String: String] = [:]
    @Published var userPositions: [Position] = []
    var userPositionIds: [String] = []
    var positions: [Position] = []
    
    func loadCurrentUser(completion: @escaping () -> Void) async throws {
        Task {
            do {
                // get authData for current user
                let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
                // use authData to get user data from Firestore as DBUser struct
                self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
                // get optional key set
                self.keySet = try await KeySetManager.shared.getKeySetForUser(userId: authDataResult.uid)
                // get optional keys for set
                self.keys = try await KeyManager.shared.getKeysForKeySet(keySetId: keySet?.id ?? "")
                
                // fetch key type for each key and add to dictionary
                for key in keys ?? [] {
                    do {
                        let keyType = try await KeyTypeManager.shared.getKeyType(keyTypeId: key.keyType ?? "")
                        keyTypeCodeMap[keyType.name] = key.keyCode
                    } catch {
                        print("Error fetching key types: \(error)")
                    }
                }
                
                self.userPositionIds = user?.positionIds ?? []
            } catch {
                print("Error loading current user: \(error)")
            }
            completion()
        }
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
    
    func getPositions(completion: @escaping () -> Void) {
        Task {
            do {
                positions = try await PositionManager.shared.getAllPositions(descending: false)
            } catch {
                print("Error getting positions: \(error)")
            }
            print("Got \(positions.count) positions.")
            
            // load position names
            // for position in user's positionIds array
            for positionId in userPositionIds {
                // find position using positionId
                guard let position = positions.first(where: { $0.id == positionId }) else { continue }
                // add to position list
                userPositions.append(position)
                // sort position list
                userPositions.sort{ $0.positionLevel ?? 0 < $1.positionLevel ?? 0 }
            }
            
            completion()
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
