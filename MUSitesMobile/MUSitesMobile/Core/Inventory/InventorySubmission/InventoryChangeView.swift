//
//  InventoryChangeView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/1/24.
//

import SwiftUI

struct InventoryChangeView: View {
    @StateObject private var viewModel = InventorySubmissionViewModel()
    @Binding var showChangeView: Bool
    @State private var reloadView = false
    @State private var showNoChangesAlert = false
    @State private var showEntryTypeAlert = false

    let inventorySite: InventorySite
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            Button(action: {
                showChangeView = false;
            }) {
                Text("Go Back")
            }
        }
    }
}

#Preview {
    NavigationView {
        InventoryChangeView(
            showChangeView: .constant(true),
            inventorySite: InventorySite(id: "TzLMIsUbadvLh9PEgqaV", name: "BCC 122", buildingId: "yXT87CrCZCoJVRvZn5DC", inventoryTypeIds: ["TzLMIsUbadvLh9PEgqaV"]))
    }
}
