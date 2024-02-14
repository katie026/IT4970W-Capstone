//
//  AuthenticationView.swift
//  MUSitesMobile
//
//  Created by J Kim on 2/14/24.
//

import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        VStack {
            NavigationLink {
                SignInEmailView()
            } label: {
                Text("Sign In with Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

#Preview {
    NavigationStack {
        AuthenticationView()
    }
}
