//
//  DetailedInventorySiteView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 3/6/24.
//

import SwiftUI
import MapKit

struct DetailedInventorySiteView: View {
    @StateObject private var viewModel = DetailedInventorySiteViewModel()
    @State private var showInventorySubmission = false
    
    public var inventorySiteId: String
    
    init(inventorySiteId: String) {
        self.inventorySiteId = inventorySiteId
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.green, .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 16) {
                Text("Inventory")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(viewModel.inventorySite?.name ?? "N/A")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Site Information
                VStack(alignment: .leading, spacing: 8) {
                    Text("Group: \(viewModel.building?.siteGroup ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Building: \(viewModel.building?.name ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Type: \(viewModel.inventoryTypes.map { $0.name }.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Keys: \(viewModel.keyTypes.map { $0.name }.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Submit Inventory Button
                if let inventorySite = viewModel.inventorySite {
                    NavigationLink(destination: InventorySubmissionView(inventorySite: inventorySite)) {
                        Text("Submit Inventory Entry")
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                } else {
                    Text("Submit Inventory Entry")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
                
                // Map
                SitesMap()
                    .frame(height: 200)
                    .cornerRadius(8)
                
                // Pictures
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<3) { _ in
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .padding(4)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Inventory Site")
        .onAppear {
            Task {
                await viewModel.loadInventorySite(inventorySiteId: inventorySiteId)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailedInventorySiteView(inventorySiteId: "TzLMIsUbadvLh9PEgqaV")
    }
}
