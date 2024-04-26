//
//  ImagePickerView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 3/26/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import SwiftUI
import UIKit

import SwiftUI

//image picker view a lil laggy but it works
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: Data?
    var completion: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func listImages(siteName: String, category: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let ref = Storage.storage().reference().child("Sites/\(siteName)/\(category)")
        ref.listAll { (result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Safely unwrap the result
            guard let result = result else {
                completion(.failure(URLError(.cannotParseResponse))) // Provide a more specific error as needed
                return
            }

            let fileNames = result.items.map { $0.name }
            completion(.success(fileNames))
        }
    }


    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage.jpegData(compressionQuality: 1.0)
            }
            picker.dismiss(animated: true, completion: parent.completion)
        }
    }
}
