//
//  VideoStreamResolution+dimensions.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-12-16.
//  Copyright (c) 2024-2025 valo.media GmbH. All rights reserved.
//

import Foundation
import AVFoundation
import AzureCommunicationCalling

// MARK: VideoStreamResolution

extension VideoStreamResolution {

    // MARK: + dimensions

    /// The dimensions of the video frame.
    /// 
    var dimensions: CMVideoDimensions {
        switch self {
        case .unknown:      return CMVideoDimensions(width: 0, height: 0)
        case .p1080:        return CMVideoDimensions(width: 1920, height: 1080)
        case .p720:         return CMVideoDimensions(width: 1280, height: 720)
        case .p540:         return CMVideoDimensions(width: 960, height: 540)
        case .p480:         return CMVideoDimensions(width: 858, height: 480)
        case .p360:         return CMVideoDimensions(width: 640, height: 360)
        case .p270:         return CMVideoDimensions(width: 480, height: 270)
        case .p240:         return CMVideoDimensions(width: 352, height: 240)
        case .p108:         return CMVideoDimensions(width: 320, height: 180)
        case .fullHd:       return CMVideoDimensions(width: 1920, height: 1080)
        case .hd:           return CMVideoDimensions(width: 1280, height: 720)
        case .vga:          return CMVideoDimensions(width: 640, height: 480)
        case .qvga:         return CMVideoDimensions(width: 320, height: 240)
        @unknown default:   return CMVideoDimensions(width: 0, height: 0)
        }
    }

}
