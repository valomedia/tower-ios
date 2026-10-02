//
//  PhotoData.swift
//  Tower_iOS
//
//

import Foundation


// MARK: PhotoData

/// The data for a photo.
///
/// This contains the Data  for an image file, along with its dimensions.
///
struct PhotoData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case imageData = "imageData"
        case imageSize = "imageSize"
    }
    
    // MARK: - Properties
    
    /// The image in a format that could be written to a file.
    ///
    var imageData: Data
    
    /// The width and height of the image.
    ///
    var imageSize: ImageSize
    
}
