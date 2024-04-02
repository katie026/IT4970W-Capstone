//
//  AdminManager.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 3/26/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

//basic overview is its just checking if the user is in the admin collection
class AdminManager {
    static let shared = AdminManager()
    
    private init() {} // Ensure singleton pattern
    
    // Function to check if the current user is an admin
    func checkIfUserIsAdmin(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        db.collection("admin").document(userId).getDocument { document, error in
            if let error = error {
                print("Error checking admin status: \(error.localizedDescription)")
                completion(false)
                return
            }
            let isAdmin = document != nil && document!.exists
            print("Is Admin: \(isAdmin)")
            completion(isAdmin)
        }
    }
}
