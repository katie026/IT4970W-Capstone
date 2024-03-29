//
//  StorageManager.swift
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

final class StorageManager {
    static let shared = StorageManager()
    private init() { }
    
    private let storage = Storage.storage().reference()

    private var imagesReferences: StorageReference {
        storage.child("sites")
    }
    
    
    func uploadImage(data: Data, siteName: String, category: String, completion: @escaping (Result<URL, Error>) -> Void) {
        // Reference to the storage location for the site's category
        let siteCategoryRef = Storage.storage().reference().child("Sites/\(siteName)/\(category)")
        
            
        // List all items in the category to determine the next image number
        siteCategoryRef.listAll { (result: StorageListResult?, error: Error?) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let result = result else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
                
            // Determine the next image name based on existing items
            let existingNames = result.items.map { $0.name }
            let nextImageName = self.determineNextImageName(from: existingNames, siteName: siteName)
                
            // Reference for the new image
            let imageRef = siteCategoryRef.child(nextImageName)
                
            // Upload the image
            imageRef.putData(data, metadata: nil) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                    
                // Retrieve the download URL
                imageRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                    } else {
                        completion(.failure(URLError(.badServerResponse)))
                    }
                }
            }
        }
    }
    private func determineNextImageName(from existingNames: [String], siteName: String) -> String {
        let siteImageNumbers = existingNames.compactMap { name -> Int? in
            guard name.hasPrefix(siteName) else { return nil }
            return Int(name.trimmingCharacters(in: CharacterSet(charactersIn: "\(siteName)_").union(.letters)))
        }
            
        if let maxNumber = siteImageNumbers.max() {
            return "\(siteName)_\(String(format: "%02d", maxNumber + 1)).jpg"
        } else {
            return "\(siteName)_01.jpg"
        }
    }
}
