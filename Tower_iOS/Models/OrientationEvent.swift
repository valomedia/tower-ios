//
//  OrientationEvent.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-12-18.
//  Copyright (c) 2024 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: OrientationEvent

/// The data sent in an orientation-event realtime data message.
///
struct OrientationEvent: Codable {

    enum CodingKeys: String, CodingKey {
        case rotationAngle = "rotationAngle"
    }

    // MARK: - Properties

    var rotationAngle: Double?

}
