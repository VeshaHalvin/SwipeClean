//
//  PhotoBinView.swift
//  SwipeClean
//
//  Created by 20 on 2025/6/3.
//

// MARK: - PhotoBinView
/// A view that manages photos marked for deletion
///
/// Features:
/// - Grid display of photos in the bin
/// - Multi-select functionality
/// - Batch restore and delete operations
/// - Permanent deletion confirmation
/// - Status messages for operations
///
/// The view provides a temporary storage area for photos before permanent deletion,
/// allowing users to recover accidentally deleted photos.

import SwiftUI

// MARK: - Main View
struct PhotoBinView: View {
    // MARK: - Properties
    
    /// View model containing the photo library data
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    
    /// Set of selected photo IDs for batch operations
    @State private var selectedPhotos = Set<UUID>()
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Empty State
                if viewModel.photoBin.isEmpty {
                    Text("No photos in bin")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // MARK: - Photo Grid
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                            ForEach(viewModel.photoBin) { photo in
                                // MARK: - Photo Cell
                                ZStack(alignment: .topTrailing) {
                                    // Photo Image
                                    Image(uiImage: photo.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .overlay(
                                            // Selection Overlay
                                            Group {
                                                if selectedPhotos.contains(photo.id) {
                                                    Color.blue.opacity(0.3)
                                                }
                                            }
                                        )

                                    // Selection Indicator
                                    if selectedPhotos.contains(photo.id) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                            .padding(4)
                                    }
                                }
                                .contentShape(Rectangle())
                                // Selection Gesture
                                .onTapGesture {
                                    if selectedPhotos.contains(photo.id) {
                                        selectedPhotos.remove(photo.id)
                                    } else {
                                        selectedPhotos.insert(photo.id)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                // MARK: - Action Buttons
                if !viewModel.photoBin.isEmpty {
                    VStack(spacing: 16) {
                        // Status Message
                        if !viewModel.deletionResultMessage.isEmpty {
                            Text(viewModel.deletionResultMessage)
                                .foregroundColor(viewModel.deletionResultMessage.contains("Successfully") ? .green : .red)
                                .padding()
                        }
                        
                        // Action Buttons
                        HStack(spacing: 20) {
                            // Restore Button
                            if !selectedPhotos.isEmpty {
                                Button {
                                    viewModel.restoreSelected(selectedPhotos)
                                    selectedPhotos.removeAll()
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.uturn.backward")
                                        Text("Restore")
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                }
                            }
                            
                            // Delete Permanently Button
                            Button {
                                viewModel.confirmPermanentDeletion()
                            } label: {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Delete Permanently")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                            }
                            .disabled(viewModel.deletionInProgress)
                        }
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Photo Bin")
            // MARK: - Deletion Confirmation Alert
            .alert(isPresented: $viewModel.showDeletionConfirmation) {
                Alert(
                    title: Text("Confirm Permanent Deletion"),
                    message: Text("Are you sure you want to permanently delete these photos? This action cannot be undone and will remove the photos from your device."),
                    primaryButton: .destructive(Text("Delete Permanently")) {
                        viewModel.performPermanentDeletion()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

// MARK: - Preview Provider
struct PhotoBinView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoBinView()
            .environmentObject(PhotoLibraryViewModel())
    }
}
