//
//  DetailedUserView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/12/24.
//

import SwiftUI

struct DetailedUserView: View {
    let user: DBUser
    
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
                Text(user.fullName ?? "N/A")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(user.email ?? "N/A")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // if user has name, display it
                if let name = user.fullName {
                    Text("Name: \(name)")
                }
                
                // photo url
                if let photoURL = user.photoURL {
                    AsyncImage(url: URL(string: photoURL))
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("User Info")
    }
}

#Preview {
    DetailedUserView(user: DBUser(userId: "oeWvTMrqMza2nebC8mImsFOaNVL2", isAnonymous: false, hasAuthentication: true, email: "ka@gmail.com", fullName: "Example Name", photoURL: "https://lh3.googleusercontent.com/a/ACg8ocIonA7UjQCTfY-8P4NDZM2HB8K8_K-ZOnj3CJl5fikw=s96-c", dateCreated: Date(timeIntervalSinceNow: TimeInterval(0)), isClockedIn: true, positions: ["CO","SS","CS"], chairReport: ChairReport(chairType: "physics_black", chairCount: 20)))
}
