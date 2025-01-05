//
//  CMVideoDimensions+CustomStringConvertible.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-12-17.
//  Copyright (c) 2024-2025 valo.media GmbH. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: CMVideoDimensions

extension CMVideoDimensions: @retroactive CustomStringConvertible {

    // MARK: + CustomStringConvertible

    public var description: String {
        "\(width)x\(height)"
    }

}
