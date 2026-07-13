//
//  CMVideoDimensions+Haschable.swift
//  tower-ios
//
//  Copyright (c) 2024-2025 valo.media GmbH. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: CMVideoDimensions

extension CMVideoDimensions: @retroactive Hashable {

    // MARK: + Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }

}
