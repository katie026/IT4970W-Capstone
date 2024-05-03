//
//  ContentView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/13/24.
//

import SwiftUI

@MainActor
final class ContentViewModel: ObservableObject {
    var structList: [Site] = []
    
    func getStructsFromFirestore(completion: @escaping () -> Void) {
        Task {
            do {
                self.structList = try await SitesManager.shared.getAllSites(descending: false)
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
    @State private var multiSelection = Set<String>()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            if isLoading {
                ProgressView()
            } else {
                List(viewModel.structList, selection: $multiSelection) { item in
                    Text("\(item.name ?? "N/A")")
                }
                .listStyle(.insetGrouped)
                .toolbar {
                    EditButton()
                }
                .onChange(of: multiSelection) { oldValue, newValue in
                    print(newValue)
                }
            }
            Text("\(multiSelection.count) selections")
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
    NavigationView {
        ContentView()
    }
}
