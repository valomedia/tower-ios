//
//  Message.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-12-18.
//  Copyright (c) 2024 valo.media GmbH. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: Message

protocol Message: Codable {}

// MARK: DataMessage

///
///
enum DataMessage: Message {

    /// Information needed to reassemble chunks into a complete image.
    ///
    /// The total number of chunks of a chunked image, along with an index into the set of chunks, and a UUID to help
    /// identifying chunks belonging to the same set.
    ///
    struct ImageChunkingInfo: Codable {
        
        enum CodingKeys: String, CodingKey {
            case index = "index"
            case count = "count"
            case uuid = "uuid"
        }
        
        // MARK: - Properties
        
        /// The index of this chunk in the set it belongs to.
        ///
        var index: Int
        
        /// The total number of chunks in the set this chunk belongs to.
        ///
        var count: Int
        
        /// A uuid that is the same for all PhotoDataChunks belonging to the same photo.
        ///
        var uuid: UUID
        
    }

    case capturePhotoRequest
    
    case capturePhotoResponse(uuid: UUID)
    
    case switchCameraRequest
    
    case switchCameraResponse
    
    case toggleTorchRequest
    
    case toggleTorchResponse
    
    case locationRequest
    
    case locationResponse
    
    case holdEvent
    
    case resumeEvent
    
    /// The data sent in a capture-photo-response realtime data message.
    ///
    /// This contains a base64-encoded chunk of the actual image file, along with the metadata that is needed to
    /// reassemble the chunks and display the image.
    ///
    /// - Parameter imageData:      The base64-encoded String of one chunk of the PhotoData.
    /// - Parameter imageSize:      The width and height of the full image.
    /// - Parameter chunkingInfo:   The information needed to reassable the chunks into a complete image.
    ///
    case photoDataEvent(
        imageData: String,
        imageSize: ImageSize,
        chunkingInfo: ImageChunkingInfo
    )
    
    /// The data sent in a location-event realtime data message.
    ///
    /// This is the location information sent to the server (a subset of the data contained in a CLLocation, but with
    /// non-optional latitude and longitude).
    ///
    /// - Parameter coordinate:         The geographical coordinate information.
    /// - Parameter altitude:           The altitude above mean sea level, in meters.
    /// - Parameter horizontalAccuracy: The radius of uncertainty for the location, in meters.
    /// - Parameter verticalAccuracy:   The estimated uncertainty for the altitude value, in meters.
    /// - Parameter course:             The direction in which the device is heading, in degrees relative to due north.
    /// - Parameter courseAccuracy:     The accuracy of the course value, in degrees.
    /// - Parameter timestamp:          The time at which the location was determined.
    ///
    case locationEvent(
        coordinate: CLLocationCoordinate2D,
        altitude: CLLocationDistance?,
        horizontalAccuracy: CLLocationAccuracy?,
        verticalAccuracy: CLLocationAccuracy?,
        course: CLLocationDirection?,
        courseAccuracy: CLLocationDirectionAccuracy?,
        timestamp: Date)
    
    case orientationEvent(rotationAngle: Double)
    
    // Mark: - Life cycle methods
    
    init?(_ location: Location) {
        guard let coordinate = location.coordinate else { return nil }
        self = .locationEvent(
            coordinate: coordinate,
            altitude: location.altitude,
            horizontalAccuracy: location.horizontalAccuracy,
            verticalAccuracy: location.verticalAccuracy,
            course: location.course,
            courseAccuracy: location.courseAccuracy,
            timestamp: location.timestamp)
    }

}

// MARK: ErrorMessage

///
///
enum ErrorMessage: Message {
    
    case capturePhotoResponse(error: String, localizedError: String? = nil)
    
    case switchCameraResponse(error: String, localizedError: String? = nil)
    
    case toggleTorchResponse(error: String, localizedError: String? = nil)
    
    case locationResponse(error: String, localizedError: String? = nil)
    
    case locationEvent(error: String, localizedError: String? = nil)
    
    case errorEvent(error: String, localizedError: String? = nil)

}

// MARK: ChunkingInfo
