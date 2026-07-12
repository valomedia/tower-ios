//
//  CMVideoDimensions+aspectRatio.swift
//  tower-ios
//
//  Copyright (c) 2024-2025 valo.media GmbH. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: CMVideoDimensions

extension CMVideoDimensions {

    // MARK: + aspectRatio

    /// The aspect ratio of the video.
    ///
    /// This will be greater than one, if the video is wider than tall.
    /// 
    var aspectRatio: Double { Double(width) / Double(height) }

}
