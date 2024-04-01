//
//  InventoryChangeView.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 4/1/24.
//

import SwiftUI

struct InventoryChangeView: View {
    @StateObject private var viewModel = InventorySubmissionViewModel()
//    @Binding var showChangeView: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var parentPresentationMode: PresentationMode
    
    @State private var reloadView = false
    @State private var showNoChangesAlert = false
    @State private var showEntryTypeAlert = false

    let inventorySite: InventorySite
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            Button(action: {
                self.popParent()
//                showChangeView = false;
            }) {
                Text("Go Back")
            }
        }
    }
    
    func popParent() {
        presentationMode.wrappedValue.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(0.001)) { self.parentPresentationMode.dismiss() }
    }
}

// MARK: Structs for Preview

private struct ParentPresentationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationLink("Confirm & Continue",
                       destination: InventoryChangeView(
                        parentPresentationMode: self.presentationMode,
                        inventorySite: InventorySite(
                            id: "TzLMIsUbadvLh9PEgqaV",
                            name: "BCC 122",
                            buildingId: "yXT87CrCZCoJVRvZn5DC",
                            inventoryTypeIds: ["TzLMIsUbadvLh9PEgqaV"]
                        )
                       )
        )
    }
}

#Preview {
    ParentPresentationView()
//    NavigationView {
//        InventoryChangeView(
//            showChangeView: .constant(true),
//            parentPresentationMode: .constant(@Environment(\.presentationMode)),
//            inventorySite: InventorySite(
//                id: "TzLMIsUbadvLh9PEgqaV",
//                name: "BCC 122",
//                buildingId: "yXT87CrCZCoJVRvZn5DC",
//                inventoryTypeIds: ["TzLMIsUbadvLh9PEgqaV"]
//            )
//        )
//    }
}
