//
//  NonAuthUserCellView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/12/24.
//

import SwiftUI

struct NonAuthUserCellView: View {
    let user: DBUser
    
    var body: some View {
        NavigationLink(destination: DetailedUserView(user: user)) {
            HStack(alignment: .top) {
                 AsyncImage(url: URL(string: user.photoURL ?? "")) { image in
//                AsyncImage(url: URL(string: "https://i.dummyjson.com/data/products/19/1.jpg")) {image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading) {
                    Text("\(user.fullName ?? "N/A")")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("ID: \(user.userId)")
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                
            }
        }
    }
}

#Preview {
    NonAuthUserCellView(
        user: DBUser(
            userId: "oeWvTMrqMza2nebC8mImsFOaNVL2",
            studentId: 12572353,
            isAnonymous: false,
            hasAuthentication: true,
            email: "ka@gmail.com",
            fullName: "Example Name", photoURL: "https://lh3.googleusercontent.com/a/ACg8ocIonA7UjQCTfY-8P4NDZM2HB8K8_K-ZOnj3CJl5fikw=s96-c",
            dateCreated: Date(timeIntervalSinceNow: TimeInterval(0)),
            isClockedIn: true,
            positions: ["CO","SS","CS"],
            chairReport: ChairReport(chairType: "physics_black", chairCount: 20)
        )
    )
}
