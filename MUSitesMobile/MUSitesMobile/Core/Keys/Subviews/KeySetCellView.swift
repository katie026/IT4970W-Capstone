//
//  KeySetCellView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/7/24.
//

import SwiftUI

@MainActor
final class KeySetCellViewModel: ObservableObject {
    @Published private(set) var keySetUser: DBUser? = nil
    
    func getKeySetUser(userId: String) {
        Task {
            self.keySetUser = try await UserManager.shared.getUser(userId: userId)
        }
        print("tried to get user \(userId)")
    }
}

struct KeySetCellView: View {
    @StateObject private var viewModel = KeySetCellViewModel()
    
    let keySet: KeySet
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("\(keySet.name ?? "N/A")")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Name: \(keySet.nickname ?? "N/A")")
                HStack {
                    if keySet.userId != "" {
                        Text("\(viewModel.keySetUser?.email ?? "N/A")")
                            .font(.callout)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        .onAppear {
            Task {
                viewModel.getKeySetUser(userId: keySet.userId ?? "")
                print("\(viewModel.keySetUser?.email ?? "no user")")
            }
        }
    }
}

#Preview {
    KeySetCellView(keySet: KeySet(id: "kALdFsUSxOGTmoz6ONlJ", name: "SS01", nickname: "Master Set", notes: "", buildingId: "b123", lastChecked: Date(timeIntervalSinceNow: TimeInterval(0)), staticLocation: false, userId: "ezWofRU3EjNXlXey5P446UeQH6B3"))
    // Oreto's Id: ezWofRU3EjNXlXey5P446UeQH6B3
    // Katie's Id: oeWvTMrqMza2nebC8mImsFOaNVL2
}
