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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(imageURLs, id: \.self) { imageUrl in
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .matchedGeometryEffect(id: imageUrl, in: animationNamespace)
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
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                    }
                }
            }
            .frame(height: 100)
            .padding(.horizontal)

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

                // Close button with better styling
                CloseButton {
                    withAnimation(.easeInOut) {
                        self.selectedImageURL = nil
                    }
                }
                .padding(.top, safeAreaInsets().top)
                .padding(.trailing, 20)
                .transition(.opacity)
                .zIndex(2)
            }
        }
    }

    @ViewBuilder
    private func CloseButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 10))
                .foregroundColor(.white)
                
                .padding(.trailing, -500)
                .padding(.top, -50)
                .background(Color.black.opacity(0.6).cornerRadius(20))
        }
    }

    private func safeAreaInsets() -> UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        guard let window = windowScene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
}

struct BoardView: View {
    var imageURLs: [URL]
    @State private var selectedImageURL: URL?
    @Namespace private var animationNamespace

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(imageURLs, id: \.self) { imageUrl in
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .matchedGeometryEffect(id: imageUrl, in: animationNamespace)
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
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                    }
                }
            }
            .frame(height: 100)
            .padding(.horizontal)

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

                // Close button with better styling
                CloseButton {
                    withAnimation(.easeInOut) {
                        self.selectedImageURL = nil
                    }
                }
                .padding(.top, safeAreaInsets().top)
                .padding(.trailing, 20)
                .transition(.opacity)
                .zIndex(2)
            }
        }
    }

    @ViewBuilder
    private func CloseButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 10))
                .foregroundColor(.white)
                
                .padding(.trailing, -500)
                .padding(.top, -50)
                .background(Color.black.opacity(0.6).cornerRadius(20))
        }
    }

    private func safeAreaInsets() -> UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        guard let window = windowScene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
}

public struct InventoryView: View {
    var imageURLs: [URL]
    @State private var selectedImageURL: URL?
    @Namespace private var animationNamespace

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(imageURLs, id: \.self) { imageUrl in
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .matchedGeometryEffect(id: imageUrl, in: animationNamespace)
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
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                    }
                }
            }
            .frame(height: 100)
            .padding(.horizontal)

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

                // Close button with better styling
                CloseButton {
                    withAnimation(.easeInOut) {
                        self.selectedImageURL = nil
                    }
                }
                .padding(.top, safeAreaInsets().top)
                .padding(.trailing, 20)
                .transition(.opacity)
                .zIndex(2)
            }
        }
    }

    @ViewBuilder
    private func CloseButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 10))
                .foregroundColor(.white)
                
                .padding(.trailing, -500)
                .padding(.top, -50)
                .background(Color.black.opacity(0.6).cornerRadius(20))
        }
    }

    private func safeAreaInsets() -> UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        guard let window = windowScene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
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
                        Image(systemName: "person.crop.circle.fill")  // Placeholder image
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
                Image(systemName: "person.crop.circle.fill")  // Placeholder image if URL is nil
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
            }
        }
        .frame(width: 50, height: 50)
    }
}





