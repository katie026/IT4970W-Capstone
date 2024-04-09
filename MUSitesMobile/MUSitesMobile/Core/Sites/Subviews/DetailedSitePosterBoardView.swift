//
//  DetailedSitePosterBoardView.swift
//  MUSitesMobile
//
//  Created by Karch Hertelendy on 3/29/24.
//

import Foundation
import SwiftUI

struct PostersView: View {
    var imageURLs: [URL]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(imageURLs, id: \.self) { imageUrl in
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                 .aspectRatio(contentMode: .fill)
                        case .failure(_):
                            Image(systemName: "photo")
                                .resizable()
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                }
            }
        }
        .frame(height: 100)
        .padding(.horizontal)
    }
}

struct BoardView: View {
    var imageURLs: [URL]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(imageURLs, id: \.self) { imageUrl in
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                 .aspectRatio(contentMode: .fill)
                        case .failure(_):
                            Image(systemName: "photo")
                                .resizable()
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                }
            }
        }
        .frame(height: 100)
        .padding(.horizontal)
    }
}

public struct InventoryView: View {
    public var imageURLs: [URL]
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(imageURLs, id: \.self) { imageUrl in
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                 .aspectRatio(contentMode: .fill)
                        case .failure(_):
                            Image(systemName: "photo")
                                .resizable()
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                }
            }
        }
        .frame(height: 100)
        .padding(.horizontal)
    }
}
