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
struct CategoryPickerView: View {
    var selectedSiteName: String

    var body: some View {
        List(["Posters", "Board", "Inventory", "ProfilePicture"], id: \.self) { category in
            NavigationLink(destination: ImageUploadView(siteName: selectedSiteName, category: category)) {
                Text(category)
            }
        }
        .navigationTitle("Select a Category")
    }
}

