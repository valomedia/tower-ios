//
//  CallQualityLevel.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-11-02.
//
//

import Foundation
import AmazonChimeSDK

// MARK: CallQualityLevel

/// Different presets for the video quality for the call.
///
enum CallQualityLevel: Int, Codable {
    
    /// Max 180p15 @ 200 kbit/s.
    ///
    case veryLow = 1
    
    /// Max 360p15 @ 600 kbit/s.
    ///
    case low = 2
    
    /// Max 540p15 @ 1400 kbit/s.
    ///
    case medium = 3
    
    /// Max 720p15 @ 2500 kbit/s.
    ///
    case high = 4
    
    /// Max 720p30 @ 2500 kbit/s.
    ///
    case veryHigh = 5
    
    /// The resolution and frame rate to use for the video transmission.
    ///
    var videoFormat: VideoCaptureFormat {
        switch self {
        case .veryLow: return VideoCaptureFormat(width: 320, height: 180, maxFrameRate: 15)
        case .low: return VideoCaptureFormat(width: 640, height: 360, maxFrameRate: 15)
        case .medium: return VideoCaptureFormat(width: 960, height: 540, maxFrameRate: 15)
        case .high: return VideoCaptureFormat(width: 1280, height: 720, maxFrameRate: 15)
        case .veryHigh: return VideoCaptureFormat(width: 1280, height: 720, maxFrameRate: 30)
        }
    }
    
    /// The maximum bandwith required by each call quality level.
    ///
    var maximumBandwidth: UInt32 {
        switch self {
        case .veryLow: return 200
        case .low: return 600
        case .medium: return 1400
        default: return 2500
        }
    }
    
}
