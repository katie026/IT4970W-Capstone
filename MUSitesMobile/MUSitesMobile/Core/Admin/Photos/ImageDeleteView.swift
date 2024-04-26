//
//  ImageDeleteView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 4/25/24.
//
import SwiftUI 

struct ImageDeleteView: View {
    var siteName: String
    var category: String
    @State private var images: [String] = []
    @State private var isLoading = true

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

    @State private var showingDeleteConfirmation = false
    @State private var selectedImageName = ""

    private func loadImages() {
        StorageManager.shared.listImages(siteName: siteName, category: category) { result in
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

    private func showDeleteConfirmation(imageName: String) {
        selectedImageName = imageName
        showingDeleteConfirmation = true
    }

    private func deleteImage(_ imageName: String) {
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
