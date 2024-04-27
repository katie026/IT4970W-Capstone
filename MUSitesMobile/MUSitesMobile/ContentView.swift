//
//  ContentView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/13/24.
//

import SwiftUI

@MainActor
final class ContentViewModel: ObservableObject {
    var structList: [Position] = []
    func getStructsFromFirestore(completion: @escaping () -> Void) {
        Task {
            do {
                self.structList = try await PositionManager.shared.getAllPositions(descending: false)
            } catch {
                print("Error getting structs: \(error)")
            }
            print("Got \(structList.count) structs")
            completion()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            if isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(viewModel.structList) { item in
                        Text(item.name ?? "N/A")
                    }
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.getStructsFromFirestore() {
                isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
}
