//
//  ImageDeleteView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 4/25/24.
//
import SwiftUI 
import FirebaseFirestore

struct ImageDeleteView: View {
    var siteName: String
    var selectedSiteId: String
    var category: String

    @State private var images: [String] = []
    @State private var isLoading = true
    @State private var showingDeleteConfirmation = false
    @State private var selectedImageName = ""
    
    var body: some View {
        List(images, id: \.self) { imageName in
            Button(imageName) {
                showDeleteConfirmation(imageName: imageName)
            }
        }
        .onAppear {
            loadImages()
        }
        .navigationTitle("\(category) Images")
        .alert("Delete Image?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteImage(selectedImageName)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this image?")
        }
    }
    private func loadImages() {
        if category == "Posters" {
            // Fetch posters specific to the selected site
            Firestore.firestore().collection("posters")
                .whereField("computing_site", isEqualTo: selectedSiteId)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Failed to load posters: \(error.localizedDescription)")
                        self.isLoading = false
                        return
                    }
                    
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        print("No posters found for the site.")
                        self.isLoading = false
                        return
                    }

                    // Resolve each poster to its corresponding image name in the poster_types collection
                    let group = DispatchGroup()
                    var imageNames = [String]()
                    
                    documents.forEach { doc in
                        guard let posterTypeId = doc.data()["poster_type"] as? String else { return }
                        
                        group.enter()
                        Firestore.firestore().collection("poster_types").document(posterTypeId)
                            .getDocument { (typeDoc, error) in
                                if let error = error {
                                    print("Error fetching poster type: \(error.localizedDescription)")
                                } else if let imageName = typeDoc?.data()?["image"] as? String {
                                    imageNames.append(imageName)
                                }
                                group.leave()
                            }
                    }
                    
                    group.notify(queue: .main) {
                        self.images = imageNames
                        self.isLoading = false
                    }
                }
        } else {
            // For other categories, continue as before
            StorageManager.shared.listImages(category: category) { result in
                switch result {
                case .success(let imageFiles):
                    self.images = imageFiles
                    self.isLoading = false
                case .failure(let error):
                    print("Failed to load images: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }

    private func showDeleteConfirmation(imageName: String) {
        selectedImageName = imageName
        showingDeleteConfirmation = true
    }

    private func deleteImage(_ imageName: String) {
        if category == "Posters" {
            deletePosterDocument(imageName)

        } else {
            StorageManager.shared.deleteImage(siteName: siteName, category: category, imageName: imageName) { result in
                switch result {
                case .success():
                    print("Image deleted successfully")
                    images.removeAll { $0 == imageName }
                case .failure(let error):
                    print("Failed to delete image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func deletePosterDocument(_ imageName: String) {
        // First, find the poster_type ID from the poster_types collection where the image matches imageName
        let posterTypesRef = Firestore.firestore().collection("poster_types")
        posterTypesRef.whereField("image", isEqualTo: imageName).getDocuments { (typeSnapshot, typeError) in
            if let typeError = typeError {
                print("Error fetching poster types: \(typeError.localizedDescription)")
                return
            }
            
            guard let typeDocs = typeSnapshot?.documents, !typeDocs.isEmpty else {
                print("No poster types found for image: \(imageName)")
                return
            }
            
            // Extract all matching poster_type IDs
            let typeIds = typeDocs.map { $0.documentID }
            print("Matching poster_type IDs found: \(typeIds)")

            // Then, delete all posters that match these type IDs and belong to the specified computing_site
            let postersRef = Firestore.firestore().collection("posters")
            typeIds.forEach { typeId in
                postersRef.whereField("computing_site", isEqualTo: self.selectedSiteId)
                           .whereField("poster_type", isEqualTo: typeId)
                           .getDocuments { (posterSnapshot, posterError) in
                               if let posterError = posterError {
                                   print("Error fetching posters: \(posterError.localizedDescription)")
                                   return
                               }
                               
                               guard let posterDocs = posterSnapshot?.documents, !posterDocs.isEmpty else {
                                   print("No posters found for type ID: \(typeId) at site: \(self.selectedSiteId)")
                                   return
                               }
                               
                               print("Deleting \(posterDocs.count) posters...")
                               for document in posterDocs {
                                   document.reference.delete { error in
                                       if let error = error {
                                           print("Error deleting poster: \(error.localizedDescription)")
                                       } else {
                                           print("Poster deleted successfully")
                                           self.images.removeAll { $0 == imageName }
                                       }
                                   }
                               }
                           }
            }
        }
    }

}

