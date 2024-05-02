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
        return storage.child("Posters")
    }

    func uploadImage(data: Data, basePath: String, siteName: String, category: String, completion: @escaping (Result<URL, Error>) -> Void) {
        // Construct the full path by combining the base path, site name, and category
        let fullPath = "\(basePath)/\(siteName)/\(category)"
        let siteCategoryRef = Storage.storage().reference().child(fullPath)
        
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

    func deleteImage(basePath: String, imageName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Reference to the specific image in the storage
        let imageRef = Storage.storage().reference().child("\(basePath)/\(imageName)")

        // Perform the deletion
        imageRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func listImages(basePath: String, category: String, completion: @escaping (Result<[String], Error>) -> Void) {
        // Construct the full path by appending the category to the basePath
        let ref = Storage.storage().reference().child("\(basePath)/\(category)")
        
        ref.listAll { (result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let result = result else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }
            let fileNames = result.items.map { $0.name }
            completion(.success(fileNames))
        }
    }

    private func determineNextImageName(from existingNames: [String], siteName: String) -> String {
//        let siteImageNumbers = existingNames.compactMap { name -> Int? in
//            guard name.hasPrefix(siteName) else { return nil }
//            return Int(name.trimmingCharacters(in: CharacterSet(charactersIn: "\(siteName)_").union(.letters)))
//        }
        let siteImageNumbers = existingNames.compactMap { name -> Int? in
            let nameComponents = name.components(separatedBy: CharacterSet.decimalDigits.inverted)
            return nameComponents.compactMap { Int($0) }.last
        }

            
        if let maxNumber = siteImageNumbers.max() {
            return "\(siteName)_\(String(format: "%02d", maxNumber + 1)).jpg"
        } else {
            return "\(siteName)_01.jpg"
        }
    }
}

