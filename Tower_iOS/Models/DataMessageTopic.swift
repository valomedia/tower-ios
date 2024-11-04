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
enum DataMessageTopic: String {
    case capturePhotoRequest = "capture-photo-request"
    case capturePhotoResponse = "capture-photo-response"
    case switchCameraRequest = "switch-camera-request"
    case switchCameraResponse = "switch-camera-response"
    case toggleTorchRequest = "toggle-torch-request"
    case toggleTorchResponse = "toggle-torch-response"
    case locationRequest = "location-request"
    case locationResponse = "location-response"
    case locationEvent = "location-event"
    case restartVideoRequest = "restart-video-request"
    case restartVideoResponse = "restart-video-response"
}
