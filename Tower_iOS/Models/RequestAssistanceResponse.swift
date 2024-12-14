//
//  RequestAssistanceResponse.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-12-10.
//  Copyright (c) 2024 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: RequestAssistanceResponse

/// The data returned by the `/requestAssistance`-endpoint.
///
struct RequestAssistanceResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case userToken = "userToken"
        case keepaliveInterval = "keepaliveInterval"
    }

    // MARK: - Properties

    /// The access token for the upcoming assistance session.
    ///
    var userToken: UserToken

    /// How often to send a request to the `/awaitAssistance`-endpoint.
    ///
    var keepaliveInterval: Int?

}
