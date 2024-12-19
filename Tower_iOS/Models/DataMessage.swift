//
//  DataMessage.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-12-18.
//  Copyright (c) 2024 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: DataMessage

///
///
struct DataMessage: Codable {

    enum CodingKeys: String, CodingKey {
        case orientationEvent = "orientationEvent"
        case errorEvent = "errorEvent"
    }

    // MARK: - Properties

    var orientationEvent: OrientationEvent?

    var errorEvent: ErrorEvent?

}
