//
//  Message.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-12-18.
//  Copyright (c) 2024-2025 valo.media GmbH. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: Message

/// A data channel Message.
///
protocol Message: Codable {}

// MARK: DataMessage

/// A data channel Message that is sent during normal operation.
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

    /// A request for the app to take a photo.
    ///
    /// When this is received, the app will take a photo and respond with several photoDataEvents and a
    /// capturePhotoResponse.
    ///
    case capturePhotoRequest

    /// A response indicating the successful capture of a photo.
    ///
    /// This is sent to the assistant, after all the chunks of photo data have been sent out.
    ///
    /// - Parameters:
    ///   - uuid: The uuid used in the ImageChunkingInfo for the photoDataEvents for the photo this response is for.
    ///
    case capturePhotoResponse(uuid: UUID)

    /// A request for the app to switch cameras.
    ///
    /// When this is received, the app will switch to the other camera and respond with a switchCameraResponse.
    ///
    case switchCameraRequest

    /// A response indicating the camera was switched successfully.
    ///
    case switchCameraResponse

    /// A request for the app to toggle the flashlight.
    ///
    /// When this is received, the app will toggle the flashlight on or off and respond with a toggleTorchResponse.
    ///
    case toggleTorchRequest

    /// A response indicating the torch was toggled successfully.
    ///
    case toggleTorchResponse

    /// A request for the users location.
    ///
    /// When this is received, the app will ask the user for location permissions (if necessary) and respond with a
    /// locationResponse. Afterward, it will start sending locationEvents.
    ///
    case locationRequest

    /// A response indicating the users location is available.
    ///
    /// This will be sent in response to a locationRequest, if location access hasn't been previously denied. This
    /// means that either location permissions are already granted, or the user will be prompted to grant them.
    ///
    case locationResponse

    /// An event sent by tower-staff, when the assistant puts the caller on hold.
    ///
    case holdEvent

    /// An event sent by tower-staff, when the assistant resumes the call after putting it on hold.
    ///
    case resumeEvent

    /// A photoDataEvent data message.
    ///
    /// This contains a base64-encoded chunk of the actual image file, along with the metadata that is needed to
    /// reassemble the chunks and display the image.
    ///
    /// - Parameters
    ///   - imageData: The base64-encoded String of one chunk of the PhotoData.
    ///   - imageSize: The width and height of the full image.
    ///   - chunkingInfo: The information needed to reassable the chunks into a complete image.
    ///
    case photoDataEvent(
        imageData: String,
        imageSize: ImageSize,
        chunkingInfo: ImageChunkingInfo
    )
    
    /// A locationEvent data message.
    ///
    /// This is the location information sent to the assistant (a subset of the data contained in a CLLocation, but with
    /// non-optional latitude and longitude).
    ///
    /// - Parameters:
    ///   - coordinate: The geographical coordinate information.
    ///   - altitude: The altitude above mean sea level, in meters.
    ///   - horizontalAccuracy: The radius of uncertainty for the location, in meters.
    ///   - verticalAccuracy: The estimated uncertainty for the altitude value, in meters.
    ///   - course: The direction in which the device is heading, in degrees relative to due north.
    ///   - courseAccuracy: The accuracy of the course value, in degrees.
    ///   - timestamp: The time at which the location was determined.
    ///
    case locationEvent(
        coordinate: CLLocationCoordinate2D,
        altitude: CLLocationDistance?,
        horizontalAccuracy: CLLocationAccuracy?,
        verticalAccuracy: CLLocationAccuracy?,
        course: CLLocationDirection?,
        courseAccuracy: CLLocationDirectionAccuracy?,
        timestamp: Date)

    /// An orientationEvent data message.
    ///
    /// This is sent once when the call starts and then during the call whenever the device is rotated.
    ///
    /// - Parameters:
    ///   - rotationAngle: Device rotation clockwise relative to landscape left, rounded to a multiple of 90.
    ///
    case orientationEvent(rotationAngle: Double)

    /// A userHelloEvent data message.
    ///
    /// The is sent once when the call starts to transmit all the information the assistant needs about the call.
    ///
    /// - Parameters:
    ///   - systemInfo: Information about the app the user is using to connect.
    ///
    case userHelloEvent(clientInfo: ClientInfo)

    // Mark: - Life cycle methods

    /// Initializer for creating a locationEvent from a Location.
    ///
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

/// A data channel message sent when something goes wrong.
///
enum ErrorMessage: Message {

    /// An error response indicating photo capture failed.
    ///
    /// This is sent in response to a caputrePhotoRequest, when the caputre fails and no actual photo data can be sent.
    ///
    /// - Parameters:
    ///   - error: A message describing the error that occured in English.
    ///   - localizedError: A message describing the error that occured on the language of the user, if available.
    ///
    case capturePhotoResponse(error: String, localizedError: String? = nil)

    /// An error response indicating that the location is not available.
    ///
    /// This is sent if the location cannot be determined because the user has previously blocked access to the
    /// location. If the user hasn't made a decision yet (and will thus be prompted), a normal locationResponse is
    /// sent.
    ///
    /// - Parameters:
    ///   - error: A message describing the error that occured in English.
    ///   - localizedError: A message describing the error that occured on the language of the user, if available.
    ///
    case locationResponse(error: String, localizedError: String? = nil)

    /// An error event indicating that location data isn't available even though it initally seemed like it might be.
    ///
    /// This can happen if the user is prompted for location access and then denies the prompt, or if determining the
    /// location failed.
    ///
    /// - Parameters:
    ///   - error: A message describing the error that occured in English.
    ///   - localizedError: A message describing the error that occured on the language of the user, if available.
    ///
    case locationEvent(error: String, localizedError: String? = nil)

    /// A generic error event for unexpected errors.
    ///
    /// - Parameters:
    ///   - error: A message describing the error that occured in English.
    ///   - localizedError: A message describing the error that occured on the language of the user, if available.
    ///
    case errorEvent(error: String, localizedError: String? = nil)

}
