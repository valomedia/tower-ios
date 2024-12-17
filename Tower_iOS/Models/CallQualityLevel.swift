//
//  CallQualityLevel.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-11-02.
//
//

import Foundation
import AVFoundation
import AzureCommunicationCalling

// MARK: CallQualityLevel

/// The various video formats the stream will switch to depending on the quality of the connection.
///
enum CallQualityLevel: Int, Codable, CaseIterable {

    /// 180p15
    ///
    case veryLow = 1
    
    /// 270p15
    ///
    case low = 2
    
    /// 360p15
    ///
    case medium = 3
    
    /// 540p15
    ///
    case high = 4
    
    /// 720p15
    ///
    case veryHigh = 5

    /// The frame rate to use for the video transmission.
    /// 
    var frameRate: Float64 { 15 }

    /// The Azure Communications Services VideoStreamResolution that corresponds to the CallQualityLevel.
    ///
    var resolution: VideoStreamResolution {
        switch self {
        case .veryLow:  return VideoStreamResolution.p108
        case .low:      return VideoStreamResolution.p270
        case .medium:   return VideoStreamResolution.p360
        case .high:     return VideoStreamResolution.p540
        case .veryHigh: return VideoStreamResolution.p720
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
