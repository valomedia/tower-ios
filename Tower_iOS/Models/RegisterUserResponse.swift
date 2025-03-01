//
//  RegisterUserResponse.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-02-28.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: RegisterUserResponse

/// The data returned by the `/registerUser`-endpoint.
///
struct RegisterUserResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case userId = "userId"
    }

    // MARK: - Properties

    /// The unique identifier this instance of the app will supply when accessing the service.
    ///
    var userId: UUID

}
