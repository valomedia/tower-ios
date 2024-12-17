//
//  CMVideoDimensions+Haschable.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-12-17.
//  Copyright (c) 2024 valo.media GmbH. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: CMVideoDimensions

extension CMVideoDimensions: Hashable {

    // MARK: + Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }

}
