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
    @State private var selectedImageURL: URL?
    @Namespace private var animationNamespace

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // ScrollView is now conditional
            if selectedImageURL == nil {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(imageURLs, id: \.self) { imageUrl in
                            AsyncImage(url: imageUrl) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                selectedImageURL = imageUrl
                                            }
                                        }
                                case .failure(_):
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                case .empty:
                                    ProgressView()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .matchedGeometryEffect(id: imageUrl, in: animationNamespace)
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                        }
                    }
                    .frame(height: 100)
                    .padding(.horizontal)
                }
            }

            // Overlay view for expanded image
            if let selectedImageURL = selectedImageURL {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            self.selectedImageURL = nil
                        }
                    }

                AsyncImage(url: selectedImageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .matchedGeometryEffect(id: selectedImageURL, in: animationNamespace)
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    self.selectedImageURL = nil
                                }
                            }
                    case .failure(_), .empty:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(20)
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
    }
}

struct BoardView: View {
    var imageURLs: [URL]
    @State private var selectedImageURL: URL?
    @Namespace private var animationNamespace

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // ScrollView is now conditional
            if selectedImageURL == nil {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(imageURLs, id: \.self) { imageUrl in
                            AsyncImage(url: imageUrl) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                selectedImageURL = imageUrl
                                            }
                                        }
                                case .failure(_):
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                case .empty:
                                    ProgressView()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .matchedGeometryEffect(id: imageUrl, in: animationNamespace)
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                        }
                    }
                    .frame(height: 100)
                    .padding(.horizontal)
                }
            }

            // Overlay view for expanded image
            if let selectedImageURL = selectedImageURL {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            self.selectedImageURL = nil
                        }
                    }

                AsyncImage(url: selectedImageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .matchedGeometryEffect(id: selectedImageURL, in: animationNamespace)
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    self.selectedImageURL = nil
                                }
                            }
                    case .failure(_), .empty:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(20)
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
    }
}

struct InventoryView: View {
    var imageURLs: [URL]
    @State private var selectedImageURL: URL?
    @Namespace private var animationNamespace

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // ScrollView is now conditional
            if selectedImageURL == nil {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(imageURLs, id: \.self) { imageUrl in
                            AsyncImage(url: imageUrl) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                selectedImageURL = imageUrl
                                            }
                                        }
                                case .failure(_):
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                case .empty:
                                    ProgressView()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .matchedGeometryEffect(id: imageUrl, in: animationNamespace)
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                        }
                    }
                    .frame(height: 100)
                    .padding(.horizontal)
                }
            }

            // Overlay view for expanded image
            if let selectedImageURL = selectedImageURL {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            self.selectedImageURL = nil
                        }
                    }

                AsyncImage(url: selectedImageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .matchedGeometryEffect(id: selectedImageURL, in: animationNamespace)
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    self.selectedImageURL = nil
                                }
                            }
                    case .failure(_), .empty:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(20)
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
    }
}

struct ProfileImageView: View {
    var imageURL: URL?
    
    var body: some View {
        Group {
            if let imageURL = imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .cornerRadius(25)
                    case .failure(_):
                        Image(systemName: "photo.circle.fill")  // Placeholder image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .cornerRadius(25)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "photo.circle.fill")  // Placeholder image if URL is nil
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
            }
        }
        .frame(width: 50, height: 50)
    }
}





