//
//  Created by Karch Hertelendy on 4/27/24.
//

import SwiftUI
import Firebase

struct PostersSelectionView: View {
    var siteId: String
    @State private var posters: [String] = []
    @State private var isLoading = true
    
    var body: some View {
        List(posters, id: \.self) { poster in
            Button(poster) {
                addPosterToSite(posterName: poster)
            }
        }
        .onAppear {
            fetchPosters()
        }
    }
    
    private func fetchPosters() {
        StorageManager.shared.listImages(category: "Posters") { result in
            switch result {
            case .success(let images):
                posters = images
                isLoading = false
            case .failure(let error):
                print("Error fetching posters: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
    
    private func addPosterToSite(posterName: String) {
        // Query Firestore to find the poster_type with the image name that matches the selected poster
        Firestore.firestore().collection("poster_types").whereField("image", isEqualTo: posterName)
            .getDocuments { snapshot, error in
                // Check for errors and ensure there is at least one document
                if let error = error {
                    print("Error finding poster type: \(error.localizedDescription)")
                    return
                }
                guard let document = snapshot?.documents.first else {
                    print("No poster type found for the image")
                    return
                }
                // No need for optional binding here as documentID is not optional
                let posterTypeId = document.documentID
                
                // Prepare the new poster document data
                let newPoster = [
                    "id": UUID().uuidString,
                    "computing_site": self.siteId,
                    "poster_type": posterTypeId,
                    "in_good_condition": true
                ] as [String : Any]
                
                // Add the new poster document to Firestore
                Firestore.firestore().collection("posters").document(newPoster["id"] as! String).setData(newPoster) { error in
                    if let error = error {
                        print("Error adding poster: \(error.localizedDescription)")
                    } else {
                        print("Poster added successfully")
                    }
                }
            }
    }

}

