//
//  CallQualityEventData.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-11-17.
//  Copyright (c) 2024 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: CallQualityEventData

/// The data sent in a call-quality-event realtime data message.
///
struct CallQualityEventData: Codable {

    enum CodingKeys: String, CodingKey {
        case callQualityLevel = "callQualityLevel"
    }

    // MARK: - Properties

    /// The currently selected preset for the video quality of the call.
    ///
    var callQualityLevel: CallQualityLevel

}
