//
//  CreateUserView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 4/16/24.
//

import Foundation
import SwiftUI
import Firebase

struct CreateUserView: View {
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var studentID: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .onChange(of: email) { updatedEmail in
                        updateStudentID(from: updatedEmail)
                    }
                TextField("Name", text: $name)
                Text("Student ID: \(studentID)")
            }
            
            Section {
                Button("Create User") {
                    verifyAndCreateUser()
                }
            }
        }
        .navigationTitle("Create User")
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func updateStudentID(from email: String) {
        if let atIndex = email.firstIndex(of: "@") {
            studentID = String(email[..<atIndex])
        }
    }
    
    private func verifyAndCreateUser() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").whereField("email", isEqualTo: email)
        
        userRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                alertMessage = "Error checking user existence: \(err.localizedDescription)"
                showingAlert = true
            } else if querySnapshot!.documents.isEmpty {
                alertMessage = "No user found with this email. Please check the email and try again."
                showingAlert = true
            } else {
                // Proceed to create user in authenticated_emails if email exists in users collection
                createUser()
            }
        }
    }
    
    private func createUser() {
        let db = Firestore.firestore()
        let userData = [
            "name": name,
            "student_id": studentID
        ]
        
        db.collection("authenticated_emails").document(email).setData(userData) { error in
            if let error = error {
                alertMessage = "Error saving user: \(error.localizedDescription)"
                showingAlert = true
            } else {
                alertMessage = "User successfully created."
                showingAlert = true
                // Resetting form fields after successful creation
                email = ""
                name = ""
                studentID = ""
            }
        }
    }
}

#Preview {
    CreateUserView()
}
