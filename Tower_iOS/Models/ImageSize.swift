//
//  ImageSize.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-08-04.
//
//

import Foundation
import AVFoundation


// MARK: ImageSize

/// The width and height for an image.
///
struct ImageSize: Codable {
    
    enum CodingKeys: String, CodingKey {
        case width = "width"
        case height = "height"
    }
    
    // MARK: - Properties
    
    /// The image width.
    ///
    var width: Int
    
    /// The image height.
    ///
    var height: Int
    
}

// MARK: + init

extension ImageSize {
    
    /// Creates an ImageSize from CMVideoDimensions.
    ///
    /// - Parameters:
    ///     - cmVideoDimensions: The CMVideoDimensions to use as the source of truth.
    ///
    init(_ cmVideoDimensions: CMVideoDimensions) {
        self.init(width: Int(cmVideoDimensions.width), height: Int(cmVideoDimensions.height))
    }
    
}
