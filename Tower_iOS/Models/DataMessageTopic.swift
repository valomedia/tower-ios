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
    case switchCameraRequest = "switch-camera-request"
    case switchCameraResponse = "switch-camera-response"
}
