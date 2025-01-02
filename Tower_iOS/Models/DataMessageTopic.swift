//
//  DataMessageTopic.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-05-19.
//
//

import Foundation

// MARK: DataMessageTopic

/// The various messages that can be sent.
///
enum DataMessageTopic: String, CodingKey {
    case capturePhotoRequest = "capturePhotoRequest"
    case capturePhotoResponse = "capturePhotoResponse"
    case switchCameraRequest = "switchCameraRequest"
    case switchCameraResponse = "switchCameraResponse"
    case toggleTorchRequest = "toggleTorchRequest"
    case toggleTorchResponse = "toggleTorchResponse"
    case locationRequest = "locationRequest"
    case locationResponse = "locationResponse"
    case locationEvent = "locationEvent"
    case orientationEvent = "orientationEvent"
    case errorEvent = "errorEvent"
}
