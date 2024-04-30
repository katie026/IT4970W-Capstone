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

struct CategoryPickerView: View {
    var selectedSiteName: String
    var selectedSiteId: String
    //will contain the path for the images
    var basePath: String
    @State private var isDeleteMode = false

    //filter for Sites, inventory_sites, and buildings(changing up the naming will mess up the path)
    private var categories: [String] {
        switch basePath {
        case "Sites":
            return ["Posters", "Board", "ProfilePicture"]
        case "inventory_sites":
            return ["Inventory", "ProfilePicture"]
        case "buildings":
            return ["ProfilePicture"]
        default:
            return []
        }
    }
    
    var body: some View {
        VStack {
            Picker("Mode", selection: $isDeleteMode) {
                Text("Upload").tag(false)
                Text("Delete").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List(categories, id: \.self) { category in
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
            PostersSelectionView(siteId: selectedSiteId, basePath: "", siteName: "")
        }
        else if category == "Posters" && isDeleteMode == true{
            ImageDeleteView( siteName: selectedSiteName, selectedSiteId: selectedSiteId, category: "Posters", basePath: basePath)
        }
        else if isDeleteMode {
            ImageDeleteView(siteName: selectedSiteName, selectedSiteId: selectedSiteId, category: category, basePath: basePath)
        }
        //otherwise it will link to the ImageUploadView
        else {
            ImageUploadView(siteName: selectedSiteName, category: category, basePath: basePath)
        }
    }
}


