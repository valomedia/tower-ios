//
//  GetUserResponse.swift
//  tower-ios
//
//  Created by Arne Engelland on 2026-06-03.
//  Copyright (c) 2025-2026 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: GetUserResponse

/// The data returned by the `/getUser`-endpoint.
///
struct GetUserResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case user = "user"
    }

    // MARK: - Properties

    /// The user profile returned by the server.
    ///
    var user: UserProfile

}
