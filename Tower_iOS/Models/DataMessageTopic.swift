//
//  DataMessageTopic.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2023-05-19.
//  Copyright (c) 2023-2025 valo.media GmbH. All rights reserved.
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
