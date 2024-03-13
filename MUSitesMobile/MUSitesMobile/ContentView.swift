//
//  ContentView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/13/24.
//

import SwiftUI

@MainActor
final class ContentViewModel: ObservableObject {
    @Published private(set) var key: Key? = nil
    
    func loadKey() async throws -> Void {
        let keyId = "pyttfA7UVGpe7ZEA7yZt"
        self.key = try await KeyManager.shared.getKey(keyId: keyId)
        print("got key \(keyId)")
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world! I'm Katie.")
            Image(systemName: "pencil")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello world! Michael here")
            Text("Hello world! This is Karch")
            Text("Tristan :)")
            Text("Hello world! - Cassie")
            Divider()
            Button("Load key") {
                Task {
                    try? await viewModel.loadKey()
                }
            }
            Text("Key: \(viewModel.key?.keyCode ?? "none")")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
