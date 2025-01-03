//
//  CMVideoDimensions+Equatable.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-12-17.
//  Copyright (c) 2024 valo.media GmbH. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: CMVideoDimensions

extension CMVideoDimensions: @retroactive Equatable {

    // MARK: + Equatable

    public static func == (lhs: CMVideoDimensions, rhs: CMVideoDimensions) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
    }

}
