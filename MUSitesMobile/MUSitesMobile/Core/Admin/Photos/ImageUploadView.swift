//
//  ImageUploadView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 3/26/24.
//
import SwiftUI
import FirebaseStorage

struct ImageUploadView: View {
    var siteName: String
    var category: String
    @State private var imageData: Data?
    @State private var showImagePicker = false

    //very basic image picker this could look nicer
    var body: some View {
        Button("Pick Image") {
            showImagePicker = true
        }
        .sheet(isPresented: $showImagePicker, onDismiss: uploadImage) {
            ImagePickerView(selectedImage: $imageData)
        }
    }

    private func uploadImage() {
        guard let imageData = imageData else {
            print("No image data to upload")
            return
        }

        //passing to the uploadImage function in the StorageManager file
        StorageManager.shared.uploadImage(data: imageData, siteName: siteName, category: category) { result in
            switch result {
            case .success(_):
                print("Image uploaded successfully")
            case .failure(let error):
                print("Error uploading image: \(error.localizedDescription)")
            }
        }
    }
}
