//
//  CapturePhotoResponseData.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-08-01.
//
//

import Foundation


// MARK: CapturePhotoResponseData

/// The data sent in a capture-photo-response realtime data message.
///
struct CapturePhotoResponseData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case photoData = "photoData"
        case message = "message"
    }
    
    // MARK: - Properties
    
    /// The data for the photo.
    ///
    var photoData: PhotoDataChunk?
    
    /// The error message if photo capture failed.
    ///
    var message: String?
    
}


// MARK: PhotoDataChunk

/// The data for the photo.
///
/// This contains a base64-encoded chunk of the actual image file, along with the metadata that is needed to
/// reassemble the chunks and display the image.
///
struct PhotoDataChunk: Codable {
    
    enum CodingKeys: String, CodingKey {
        case imageData = "imageData"
        case imageSize = "imageSize"
        case chunkingInfo = "chunkingInfo"
    }
    
    // MARK: - Properties
    
    /// The base64 encoded string of one chunk of image data.
    ///
    var imageData: String
    
    /// The width and height of the full image.
    ///
    var imageSize: ImageSize
    
    /// The total number of chunks, along with the index of the current chunk.
    ///
    var chunkingInfo: ChunkingInfo
    
}


// MARK: ChunkingInfo

/// The total number of chunks of a chunked image, along with an index into the set of chunks.
///
struct ChunkingInfo: Codable {
    
    enum CodingKeys: String, CodingKey {
        case index = "index"
        case count = "count"
    }
    
    // MARK: - Properties
    
    /// The index of this chunk in the set it belongs to.
    ///
    var index: Int
    
    /// The total number of chunks in the set this chunk belongs to.
    ///
    var count: Int
    
}
