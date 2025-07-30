//
//  Photo.swift
//  SwipeClean
//
//  Created by 20 on 2025/6/3.
//

// MARK: - Photo Model
/// A model representing a photo in the SwipeClean app
/// 
/// The Photo struct encapsulates all necessary information about a photo including:
/// - A unique identifier
/// - The actual image data
/// - The date the photo was taken
/// - A flag indicating if the photo should be kept or is marked for deletion
///

import Foundation
import UIKit

// MARK: - Photo Structure
struct Photo: Identifiable, Hashable {
    // MARK: Properties
    
    /// Unique identifier for the photo
    let id = UUID()
    
    /// The actual image data of the photo
    let image: UIImage
    
    /// The date when the photo was taken
    let date: Date
    
    /// Flag indicating if the photo should be kept (true) or is marked for deletion (false)
    /// Default value is true
    var isKept: Bool = true
    
    // MARK: - Hashable Conformance
    /// Hashable conformance is automatically synthesized by Swift
    /// This allows the Photo to be used in Sets and as Dictionary keys
}
