//
//  PhotoDetailView.swift
//  SwipeClean
//
//  Created by 20 on 2025/6/3.
//

// MARK: - PhotoDetailView
/// A detailed view for displaying and interacting with individual photos
///
/// Features:
/// - Full-screen photo display
/// - Gesture-based interactions (pinch to zoom, swipe to dismiss)
/// - Photo carousel navigation
/// - Actions (move to bin, save)
/// - Smooth transitions and animations
///
/// The view supports:
/// - Left/right navigation between photos
/// - Zoom and pan gestures
/// - Vertical swipe to dismiss
/// - Animated transitions

import SwiftUI

// MARK: - Main View
struct PhotoDetailView: View {
    // MARK: - Properties
    
    /// Binding to control the presentation state of the detail view
    @Binding var isShowingDetail: Bool
    
    /// View model containing the photo library data
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    
    /// The photo to display initially
    let photo: Photo
    
    /// Namespace for matched geometry transitions
    let namespace: Namespace.ID
    
    // MARK: - State Properties
    
    /// Current zoom scale of the photo
    @State private var scale: CGFloat = 1.0
    
    /// Current pan offset of the photo
    @State private var offset: CGSize = .zero
    
    /// Index of the currently displayed photo
    @State private var currentIndex: Int = 0
    
    /// Opacity for fade animations
    @State private var opacity: Double = 0
    
    // MARK: - Computed Properties
    
    /// Array of available photos from the view model
    private var photos: [Photo] {
        viewModel.availablePhotos
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // MARK: - Background
            Color.black
                .opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isShowingDetail = false
                    }
                }
            
            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                HStack {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isShowingDetail = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 44)
                
                // MARK: - Photo Carousel
                TabView(selection: $currentIndex) {
                    ForEach(Array(photos.enumerated()), id: \.element.id) { index, currentPhoto in
                        GeometryReader { proxy in
                            Image(uiImage: currentPhoto.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .scaleEffect(scale)
                                .offset(offset)
                                // MARK: - Zoom Gesture
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            scale = value
                                        }
                                        .onEnded { _ in
                                            withAnimation {
                                                scale = 1.0
                                            }
                                        }
                                )
                                // MARK: - Drag Gesture
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            offset = value.translation
                                        }
                                        .onEnded { value in
                                            withAnimation {
                                                let height = value.translation.height
                                                if abs(height) > 100 {
                                                    isShowingDetail = false
                                                }
                                                offset = .zero
                                            }
                                        }
                                )
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                
                // MARK: - Action Buttons
                HStack(spacing: 30) {
                    // Move to Bin Button
                    Button {
                        withAnimation(.spring()) {
                            if let currentPhoto = photos[safe: currentIndex] {
                                viewModel.moveToBin(currentPhoto)
                                if currentIndex == photos.count - 1 {
                                    isShowingDetail = false
                                }
                            }
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.system(size: 24))
                            Text("Move to Bin")
                                .font(.callout)
                        }
                        .foregroundColor(.white)
                        .frame(width: 100)
                        .padding(.vertical, 12)
                        .cornerRadius(15)
                    }
                    
                    // Save Button
                    Button {
                        if let currentPhoto = photos[safe: currentIndex],
                           let inputImage = currentPhoto.image.jpegData(compressionQuality: 1.0) {
                            let imageSaver = ImageSaver()
                            imageSaver.saveToPhotoAlbum(imageData: inputImage)
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 24))
                            Text("Save")
                                .font(.callout)
                        }
                        .foregroundColor(.white)
                        .frame(width: 100)
                        .padding(.vertical, 12)
                        .cornerRadius(15)
                    }
                }
                .padding(.bottom, 50)
            }
            .opacity(opacity)
            
            // MARK: - Side Navigation
            HStack {
                // Previous Button
                Button(action: {
                    withAnimation {
                        if currentIndex > 0 {
                            currentIndex -= 1
                        }
                    }
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .opacity(currentIndex > 0 ? 1 : 0.3)
                }
                .disabled(currentIndex == 0)
                
                Spacer()
                
                // Next Button
                Button(action: {
                    withAnimation {
                        if currentIndex < photos.count - 1 {
                            currentIndex += 1
                        }
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .opacity(currentIndex < photos.count - 1 ? 1 : 0.3)
                }
                .disabled(currentIndex == photos.count - 1)
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .center)
            .opacity(opacity)
        }
        .transition(.opacity)
        // MARK: - Lifecycle
        .onAppear {
            if let index = photos.firstIndex(where: { $0.id == photo.id }) {
                currentIndex = index
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                opacity = 1
            }
        }
        .onDisappear {
            scale = 1.0
            offset = .zero
        }
    }
}

// MARK: - Collection Extension
/// Adds safe subscript access to collections
extension Collection {
    /// Returns the element at the specified index if it exists, otherwise returns nil
    /// - Parameter index: The position of the element to access
    /// - Returns: The element at the specified index if it exists, nil otherwise
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class ImageSaver: NSObject {
    func saveToPhotoAlbum(imageData: Data) {
        if let image = UIImage(data: imageData) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
        }
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Save error: \(error.localizedDescription)")
        } else {
            print("Save finished!")
        }
    }
}
