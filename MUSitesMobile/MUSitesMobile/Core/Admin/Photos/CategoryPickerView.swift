//
//  CategoryPickerView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 3/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import SwiftUI
import UIKit

//view for picking category for the images currently theres only 3 but we can expand on this if we want to
//struct CategoryPickerView: View {
//    var selectedSiteName: String
//
//    var body: some View {
//        List(["Posters", "Board", "Inventory", "ProfilePicture"], id: \.self) { category in
//            NavigationLink(destination: ImageUploadView(siteName: selectedSiteName, category: category)) {
//                Text(category)
//            }
//        }
//        .navigationTitle("Select a Category")
//    }
//}
struct CategoryPickerView: View {
    var selectedSiteName: String
    var selectedSiteId: String
    @State private var isDeleteMode = false

    var body: some View {
        VStack {
            Picker("Mode", selection: $isDeleteMode) {
                Text("Upload").tag(false)
                Text("Delete").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List(["Posters", "Board", "Inventory", "ProfilePicture"], id: \.self) { category in
                NavigationLink(destination: destinationView(for: category)) {
                    Text(category)
                }
            }
        }
        .navigationTitle("Select a Category")
    }
    
    @ViewBuilder
    private func destinationView(for category: String) -> some View {
        //if in delete mode it will link to the ImageDeleteView
        if category == "Posters" && isDeleteMode == false{
            PostersSelectionView(siteId: selectedSiteId)
        }
        else if category == "Posters" && isDeleteMode == true{
            ImageDeleteView(siteName: selectedSiteName, selectedSiteId: selectedSiteId, category: "Posters")
        }
        else if isDeleteMode {
            ImageDeleteView(siteName: selectedSiteName, selectedSiteId: selectedSiteId, category: category)
        }
        //otherwise it will link to the ImageUploadView
        else {
            ImageUploadView(siteName: selectedSiteName, category: category)
        }
    }
}


