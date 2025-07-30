//
//  PhotoLibraryViewModel.swift
//  SwipeClean
//
//  Created by 20 on 2025/6/3.
//

// MARK: - PhotoLibraryViewModel
/// The main view model responsible for managing photo library operations in SwipeClean
///
/// This view model handles:
/// - Photo library access and authorization
/// - Loading and managing photos
/// - Photo bin operations (move, restore, delete)
/// - Premium features management
/// - Permanent photo deletion
///
/// Usage Example:
/// ```
/// let viewModel = PhotoLibraryViewModel()
/// viewModel.refreshPhotos()
/// ```

import SwiftUI
import PhotosUI

// MARK: - Main ViewModel Class
class PhotoLibraryViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Array of imported photos from the photo library
    @Published var importedPhotos: [Photo] = []
    
    /// Array of photos marked for deletion (in the bin)
    @Published var photoBin: [Photo] = []
    
    /// Current authorization status for photo library access
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    /// Flag indicating if deletion is in progress
    @Published var deletionInProgress = false
    
    /// Message showing the result of deletion operation
    @Published var deletionResultMessage = ""
    
    /// Flag to show deletion confirmation dialog
    @Published var showDeletionConfirmation = false
    
    /// Flag indicating if photos are being refreshed
    @Published var isRefreshing = false
    
    /// Flag indicating if user has premium status
    @Published var isPremium: Bool = false
    
    /// Flag indicating if purchase is being processed
    @Published var isProcessingPurchase: Bool = false
    
    /// Error message during purchase process
    @Published var purchaseError: String? = nil
    
    /// Flag to show premium upgrade prompt
    @Published var showPremiumPrompt: Bool = false
    
    // MARK: - Private Properties
    
    /// Assets marked for deletion
    private var assetsToDelete: [PHAsset] = []
    
    /// Mapping between photo IDs and PHAssets
    private var assetMap: [String: PHAsset] = [:]
    
    // MARK: - Computed Properties
    
    /// Returns available photos based on premium status
    /// - Returns: All photos for premium users, first 10 photos for non-premium users
    var availablePhotos: [Photo] {
        if isPremium {
            return importedPhotos
        } else {
            return Array(importedPhotos.prefix(10))
        }
    }
    
    /// Returns photos for SwipeClean feature
    /// - Returns: All photos for premium users, empty array for non-premium users
    var swipeCleanPhotos: [Photo] {
        if isPremium {
            return importedPhotos
        } else {
            if importedPhotos.count > 10 {
                showPremiumPrompt = true
            }
            return []
        }
    }
    
    /// Indicates if non-premium user has reached photo limit
    var isPhotoLimitReached: Bool {
        !isPremium && importedPhotos.count > 10
    }
    
    // MARK: - Initialization
    
    /// Initializes the view model and requests photo library access
    init() {
        requestPhotoLibraryAccess()
        // Load premium status from UserDefaults
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")
    }
    
    // MARK: - Photo Library Access
    
    /// Requests access to the photo library
    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                if status == .authorized || status == .limited {
                    self?.loadPhotosFromLibrary()
                }
            }
        }
    }
    
    /// Refreshes the photo library by reloading all photos
    func refreshPhotos() {
        isRefreshing = true
        importedPhotos.removeAll()
        assetMap.removeAll()
        loadPhotosFromLibrary()
    }
    
    /// Loads photos from the device's photo library
    /// - Note: Photos are loaded asynchronously and sorted by date
    private func loadPhotosFromLibrary() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        let group = DispatchGroup()
        var newPhotos: [(Photo, String)] = []
        
        assets.enumerateObjects { [weak self] asset, index, _ in
            group.enter()
            
            let imageManager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            
            imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 800, height: 800),
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                if let image = image {
                    let photo = Photo(image: image, date: asset.creationDate ?? Date())
                    newPhotos.append((photo, asset.localIdentifier))
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            // Sort by date before adding to importedPhotos
            let sortedPhotos = newPhotos.sorted { $0.0.date > $1.0.date }
            
            for (photo, identifier) in sortedPhotos {
                self?.importedPhotos.append(photo)
                if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject {
                    self?.assetMap[photo.id.uuidString] = asset
                }
            }
            
            self?.isRefreshing = false
        }
    }

    // MARK: - Photo Bin Operations
    
    /// Moves a photo to the bin
    /// - Parameter photo: The photo to move to bin
    func moveToBin(_ photo: Photo) {
        if let index = importedPhotos.firstIndex(of: photo) {
            importedPhotos.remove(at: index)
            photoBin.append(photo)
        }
    }

    /// Deletes a photo from the bin
    /// - Parameter photo: The photo to delete from bin
    func deleteFromBin(_ photo: Photo) {
        if let index = photoBin.firstIndex(of: photo) {
            photoBin.remove(at: index)
        }
    }

    /// Deletes selected photos from the bin
    /// - Parameter selected: Set of photo IDs to delete
    func deleteSelected(_ selected: Set<UUID>) {
        photoBin.removeAll { selected.contains($0.id) }
    }
    
    /// Restores a photo from the bin to the main collection
    /// - Parameter photo: The photo to restore
    func restoreFromBin(_ photo: Photo) {
        if let index = photoBin.firstIndex(of: photo) {
            photoBin.remove(at: index)
            importedPhotos.insert(photo, at: 0) // Add to the beginning of the collection
        }
    }
    
    /// Restores selected photos from the bin
    /// - Parameter selected: Set of photo IDs to restore
    func restoreSelected(_ selected: Set<UUID>) {
        let photosToRestore = photoBin.filter { selected.contains($0.id) }
        photoBin.removeAll { selected.contains($0.id) }
        importedPhotos.insert(contentsOf: photosToRestore, at: 0)
    }
    
    // MARK: - Permanent Deletion
    
    /// Initiates the permanent deletion confirmation process
    func confirmPermanentDeletion() {
        deletionInProgress = true
        deletionResultMessage = ""
        
        assetsToDelete = photoBin.compactMap { photo in
            assetMap[photo.id.uuidString]
        }
        
        if !assetsToDelete.isEmpty {
            showDeletionConfirmation = true
        } else {
            deletionResultMessage = "No photos found to delete permanently."
        }
        deletionInProgress = false
    }
    
    /// Performs the permanent deletion of photos from the device
    func performPermanentDeletion() {
        guard !assetsToDelete.isEmpty else { return }
        
        deletionInProgress = true
        deletionResultMessage = ""
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(self.assetsToDelete as NSFastEnumeration)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.deletionInProgress = false
                if success {
                    self?.deletionResultMessage = "Successfully deleted \(self?.assetsToDelete.count ?? 0) photos permanently."
                    self?.photoBin.removeAll()
                    self?.assetsToDelete.removeAll()
                } else {
                    self?.deletionResultMessage = "Failed to delete photos: \(error?.localizedDescription ?? "Unknown error")"
                }
            }
        }
    }

    // MARK: - Premium Features
    
    /// Handles the premium upgrade process
    /// - Note: Currently implements a simulated purchase process
    func upgradeToPremium() {
        isProcessingPurchase = true
        // Simulate purchase process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isPremium = true
            self.isProcessingPurchase = false
            self.purchaseError = nil
            // Save premium status to UserDefaults
            UserDefaults.standard.set(true, forKey: "isPremium")
        }
    }
    
    func restorePurchases() {
        isProcessingPurchase = true
        // Simulate restore process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if UserDefaults.standard.bool(forKey: "isPremium") {
                self.isPremium = true
                self.purchaseError = nil
            } else {
                self.purchaseError = "No previous purchase found"
            }
            self.isProcessingPurchase = false
        }
    }
    
    func resetPremiumStatus() {
        isProcessingPurchase = true
        // Simulate reset process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isPremium = false
            UserDefaults.standard.set(false, forKey: "isPremium")
            self.purchaseError = nil
            self.isProcessingPurchase = false
        }
    }
}

