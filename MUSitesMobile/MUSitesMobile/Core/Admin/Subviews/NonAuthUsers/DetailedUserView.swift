//
//  DetailedUserView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 4/16/24.
//

import Foundation
import SwiftUI

struct DetailedUserView: View {
    let user: DBUser
    @StateObject private var viewModel = NonAuthUsersViewModel()
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [.green, .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 16) {
                // Header
                Text("Name:")
                Text(user.fullName ?? "N/A")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Email:")
                Text(user.email ?? "N/A")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button("Delete User") {
                    viewModel.deleteUserDoc(userId: user.userId)
                }
            }
            .padding()
        }
        .navigationTitle("User Info")
    }
}
