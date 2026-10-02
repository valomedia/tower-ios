//
//  CallQualityLevel.swift
//  tower-ios
//
//  Copyright (c) 2024-2025 valo.media GmbH. All rights reserved.
//

import Foundation
import AVFoundation
import AzureCommunicationCalling

// MARK: CallQualityLevel

/// The various video formats the stream will switch to depending on the quality of the connection.
///
enum CallQualityLevel: Int, Codable, CaseIterable {

    /// VGA
    ///
    case veryLow = 1
    
    /// 540p15
    ///
    case low = 2
    
    /// 540p
    ///
    case medium = 3
    
    /// 720p
    ///
    case high = 4
    
    /// 1080p
    ///
    case veryHigh = 5

    /// The frame rate to use for the video transmission.
    /// 
    var frameRate: Float64 {
        switch self {
        case .veryLow:  return 7.5
        case .low:      return 15
        default:        return 30
        }
    }

    /// The Azure Communications Services VideoStreamResolution that corresponds to the CallQualityLevel.
    ///
    var resolution: VideoStreamResolution {
        switch self {
        case .veryLow:      return VideoStreamResolution.vga
        case .low, .medium: return VideoStreamResolution.p540
        case .high:         return VideoStreamResolution.p720
        case .veryHigh:     return VideoStreamResolution.p1080
        }
    }

    /// The Azure Communications Services VideoStreamFormat used at each CallQualityLevel.
    /// 
    var videoStreamFormat: VideoStreamFormat {
        let videoStreamFormat = VideoStreamFormat()
        videoStreamFormat.resolution = resolution
        videoStreamFormat.pixelFormat = VideoStreamPixelFormat.nv12
        videoStreamFormat.framesPerSecond = Float(frameRate)
        videoStreamFormat.stride1 = resolution.dimensions.width
        videoStreamFormat.stride2 = resolution.dimensions.width / 2
        return videoStreamFormat
    }

    /// Human-readable names for each call quality level.
    ///
    var description: String {
        switch self {
        case .veryLow: return "Very low"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .veryHigh: return "Very high"
        }
    }

    /// Localized version of the human-readable names qor each call quality level.
    ///
    var localizedDescription: String {
        switch self {
        case .veryLow: return "Sehr niedrig"
        case .low: return "Niedrig"
        case .medium: return "Mittel"
        case .high: return "Hoch"
        case .veryHigh: return "Sehr hoch"
        }
    }

}
