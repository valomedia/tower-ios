//
//  CallQualityData.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-11-17.
//  Copyright (c) 2024 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: CallQualityData

/// The data sent in realtime data messages related to call quality.
/// 
/// This contains the data that gets sent in the change-call-quality-request, change-call-quality-response and
/// call-quality-event realtime data messages.
///
struct CallQualityData: Codable {

    enum CodingKeys: String, CodingKey {
        case callQualityLevel = "callQualityLevel"
        case message = "message"
    }

    // MARK: - Properties

    /// The preset for the video quality related to this message.
    /// 
    /// For the change-call-quality-response and call-quality-event realtime data messages, this specifies the new
    /// setting being used. In a change-call-quality-request, this specifies the requested call quality.
    ///
    var callQualityLevel: CallQualityLevel?

    /// The error message if something went wrong.
    /// 
    var message: String?

}
